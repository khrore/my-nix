"""Shared configuration I/O for independent desktop theme commands."""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def write_text(path, text, *, force=False):
    old = path.read_text() if path.exists() else None
    if old == text and not force:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    # Materialize mutable app settings: never write through dotfile symlinks.
    backup = path.with_name(path.name + ".before-desktop-theme")
    if old is not None and not backup.exists():
        with backup.open("x") as output:
            os.chmod(backup, 0o600)
            output.write(old)
    descriptor, temporary = tempfile.mkstemp(dir=path.parent)
    try:
        with os.fdopen(descriptor, "w") as output:
            output.write(text)
        if path.exists():
            os.chmod(temporary, path.stat().st_mode & 0o777)
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)
    return old != text


def processes():
    result = {}
    for directory in Path("/proc").iterdir():
        if not directory.name.isdecimal():
            continue
        try:
            if directory.stat().st_uid == os.getuid():
                name = (directory / "comm").read_text().strip().lower()
                result.setdefault(name, []).append(directory)
        except OSError:
            pass
    return result


def notify_once(state, app, fingerprint, message, enabled):
    print(f"{app}: {message}")
    marker = state / (app + ".notice")
    if enabled and (not marker.exists() or marker.read_text() != fingerprint):
        if shutil.which("notify-send"):
            subprocess.run(["notify-send", "Desktop theme", message], check=False)
        write_text(marker, fingerprint)


class ThemeConfig:
    def __init__(self, app, no_notify):
        self.root = Path(
            os.environ.get(
                "LINUX_SESSION_ROOT", Path.home() / ".local/share/linux-desktop"
            )
        )
        self.theme = self.root / "current/theme"
        defaults = json.loads((self.root / "default/apps.json").read_text())
        config = (
            Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
            / "linux-desktop/apps.json"
        )
        overrides = json.loads(config.read_text()) if config.exists() else {}
        self.settings = {**defaults[app], **overrides.get(app, {})}
        self.notify = (
            overrides.get("notify", defaults.get("notify", True)) and not no_notify
        )
        self.state = (
            Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
            / "linux-desktop/apps"
        )


def run(app, action):
    parser = argparse.ArgumentParser(
        description=f"Apply the current desktop theme to {app}."
    )
    parser.add_argument("--no-notify", action="store_true")
    args = parser.parse_args()
    try:
        config = ThemeConfig(app, args.no_notify)
        if config.settings.get("enabled", True):
            action(config)
    except (
        OSError,
        ValueError,
        TypeError,
        KeyError,
        subprocess.SubprocessError,
    ) as error:
        print(f"theme-set-{app}: {error}", file=sys.stderr)
        return 1
    return 0
