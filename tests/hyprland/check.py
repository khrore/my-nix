#!/usr/bin/env python3
"""Isolated Hyprland migration checks. Requires Python, Hyprland 0.56.2 and Lua.
Run: python3 tests/hyprland/check.py [--integration]
No command targets the user's compositor or installs dotfiles.
"""

import argparse
import json
import os
import shutil
import signal
import stat
import subprocess
import tempfile
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
DOTFILES = REPO / "dotfiles/nixos"
SOURCE = DOTFILES / ".local/share/linux-desktop"


def run(command, env, *, check=True):
    result = subprocess.run(
        command,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=45,
        check=False,
    )
    if check and result.returncode:
        raise AssertionError(f"{command}:\n{result.stdout}")
    return result


def setup(home):
    config = home / ".config"
    config.mkdir()
    shutil.copytree(DOTFILES / ".config/hypr", config / "hypr")
    runtime = home / "run"
    runtime.mkdir(mode=0o700)
    root = home / ".local/share/linux-desktop"
    root.mkdir(parents=True)
    for name in ("default", "themes", "bin"):
        (root / name).symlink_to(SOURCE / name)
    shutil.copytree(SOURCE / "current", root / "current")
    env = os.environ.copy()
    for key in (
        "HYPRLAND_INSTANCE_SIGNATURE",
        "DBUS_SESSION_BUS_ADDRESS",
        "DBUS_SESSION_BUS_PID",
    ):
        env.pop(key, None)
    env.update(
        HOME=str(home),
        XDG_CONFIG_HOME=str(config),
        XDG_STATE_HOME=str(home / ".local/state"),
        XDG_CACHE_HOME=str(home / ".cache"),
        XDG_RUNTIME_DIR=str(runtime),
        LINUX_SESSION_ROOT=str(root),
        PATH=str(SOURCE / "bin") + os.pathsep + env["PATH"],
    )
    return env, root, config


def select_theme(name, env, root):
    staged = root / "current/next-theme"
    shutil.rmtree(staged, ignore_errors=True)
    shutil.copytree(SOURCE / "themes" / name, staged)
    run(["bash", str(SOURCE / "bin/theme-set-templates")], env)
    assert (staged / "hyprland.lua").is_file(), name
    run(["hyprland-theme-verify", str(staged / "hyprland.lua")], env)
    shutil.rmtree(root / "current/theme")
    staged.rename(root / "current/theme")


def theme_effect_stubs(env, *, real_reload=False):
    fake = Path(env["HOME"]) / "theme-effects"
    fake.mkdir(exist_ok=True)
    commands = (
        "theme-bg-next",
        "restart-waybar",
        "restart-swayosd",
        "restart-terminal",
        "restart-btop",
        "restart-mako",
        "theme-set-gnome",
        "theme-set-vscode",
        "theme-set-obsidian",
        "theme-set-keyboard",
        "hook",
        "pgrep",
        "notify-send",
    )
    if not real_reload:
        commands += ("restart-hyprctl",)
    for command in commands:
        stub = fake / command
        stub.write_text(
            "#!/usr/bin/env bash\nexit " + ("1" if command == "pgrep" else "0") + "\n"
        )
        stub.chmod(0o755)
    return dict(env, PATH=str(fake) + os.pathsep + env["PATH"])


def static_checks(env, root, config):
    # Real parser validates every full config, including app rules and override precedence.
    for theme in sorted((SOURCE / "themes").iterdir()):
        if theme.is_dir():
            select_theme(theme.name, env, root)
            run(
                [
                    "Hyprland",
                    "--verify-config",
                    "-c",
                    str(config / "hypr/hyprland.lua"),
                ],
                env,
            )
    print("all built-in themes + complete config: passed", flush=True)
    # The user template takes priority over the built-in template.
    user = config / "linux-desktop/themed"
    user.mkdir(parents=True)
    (user / "hyprland.lua.tpl").write_text(
        "hl.config({ general = { gaps_in = 23 } })\n"
    )
    select_theme("nord", env, root)
    assert "23" in (root / "current/theme/hyprland.lua").read_text()
    (user / "hyprland.lua.tpl").unlink()
    # Legacy templates are rejected rather than silently discarded.
    (user / "hyprland.conf.tpl").write_text("general { gaps_in = 23 }")
    result = run(["theme-set-templates"], env, check=False)
    assert result.returncode and "Migrate" in result.stdout
    (user / "hyprland.conf.tpl").unlink()
    # Invalid theme must leave the selected directory and name untouched.
    before = (root / "current/theme/hyprland.lua").read_bytes()
    name_before = (root / "current/theme.name").read_bytes()
    invalid = config / "linux-desktop/themes/broken"
    invalid.mkdir(parents=True)
    (invalid / "hyprland.lua").write_text(
        'hl.config({ general = { gaps_in = "invalid" } })'
    )
    result = run(["theme-set", "broken"], env, check=False)
    assert result.returncode
    assert (root / "current/theme/hyprland.lua").read_bytes() == before
    assert (root / "current/theme.name").read_bytes() == name_before
    # Missing required module must cause verification failure.
    override = config / "hypr/input.lua"
    override.rename(override.with_suffix(".backup"))
    result = run(
        ["Hyprland", "--verify-config", "-c", str(config / "hypr/hyprland.lua")],
        env,
        check=False,
    )
    assert result.returncode
    override.with_suffix(".backup").rename(override)
    print(
        "template priority, invalid/legacy themes and missing module: passed",
        flush=True,
    )
    run(["theme-set", "nord"], theme_effect_stubs(env))
    assert (root / "current/theme.name").read_text().strip() == "nord"
    run(["lua", str(REPO / "tests/hyprland/runtime.lua"), str(REPO)], env)
    # The shell bridge rejects both transport errors and Lua errors returned with exit 0.
    fake = Path(env["HOME"]) / "fake-bin"
    fake.mkdir()
    fake_ctl = fake / "hyprctl"
    fake_ctl.write_text(
        '#!/usr/bin/env bash\nprintf "%s\\n" "${TEST_REPLY:-ok}"\nexit "${TEST_STATUS:-0}"\n'
    )
    fake_ctl.chmod(0o755)
    fake_env = dict(env, PATH=str(fake) + os.pathsep + env["PATH"])
    assert run(["hyprland-eval", "return"], fake_env, check=False).returncode == 0
    assert (
        run(
            ["hyprland-eval", "return"],
            dict(fake_env, TEST_REPLY="Lua error"),
            check=False,
        ).returncode
        != 0
    )
    assert (
        run(
            ["hyprland-eval", "return"], dict(fake_env, TEST_STATUS="1"), check=False
        ).returncode
        != 0
    )
    for args in (
        ["1", "1", "1"],
        ['1; os.execute("bad")', "1"],
        ["1", "1", "x", "0"],
        ["0", "1"],
    ):
        assert (
            run(["hyprland-window-pop", *args], fake_env, check=False).returncode == 2
        )
    # A rejected asynchronous scale request restores the old rule and never notifies success.
    fake_ctl.write_text(
        '#!/usr/bin/env bash\nprintf \'%s\\n\' "$*" >> "$HOME/ctl-calls"\ncase "$1" in\n  eval) echo ok ;;\n  repl) if [[ $2 == desktop.scale_target ]]; then echo 1.6; else echo test; fi ;;\n  monitors) echo \'[{"name":"test","scale":1}]\' ;;\nesac\n'
    )
    for command in ("sleep", "notify-send"):
        stub = fake / command
        stub.write_text(
            "#!/usr/bin/env bash\n"
            + (
                'echo notified > "$HOME/notified"\n'
                if command == "notify-send"
                else "exit 0\n"
            )
        )
        stub.chmod(0o755)
    result = run(["hyprland-monitor-scaling-cycle"], fake_env, check=False)
    assert result.returncode == 1
    assert (
        "hl.monitor(desktop.scale_previous)"
        in (Path(env["HOME"]) / "ctl-calls").read_text()
    )
    assert not (Path(env["HOME"]) / "notified").exists()
    print("runtime decisions and shell error/argument handling: passed", flush=True)


def integration(env, root, config, parent_display):
    select_theme("lumon", env, root)
    # Intercept external startup commands; the compositor still loads the real config.
    startup = Path(env["HOME"]) / "startup.log"
    wrapper = config / "hypr/test.lua"
    wrapper.write_text(
        "hl.exec_cmd = function(command) local f = assert(io.open("
        + json.dumps(str(startup))
        + ', "a")); f:write(command, "\\n"); f:close() end\nrequire('
        + json.dumps(str(config / "hypr/hyprland.lua"))
        + ")\nhl.config({ debug = { disable_logs = false, enable_stdout_logs = true, vfr = false } })\n"
    )
    child_env = dict(env, WAYLAND_DISPLAY=parent_display, AQ_DRM_DEVICES="/dev/null")
    log = Path(env["HOME"]) / "integration.log"
    with log.open("w") as output:
        process = subprocess.Popen(
            ["dbus-run-session", "--", "Hyprland", "-c", str(wrapper)],
            env=child_env,
            stdout=output,
            stderr=output,
            start_new_session=True,
        )
        clients = []
        try:
            deadline = time.monotonic() + 25
            socket = None
            while time.monotonic() < deadline and process.poll() is None:
                matches = list(
                    (Path(env["XDG_RUNTIME_DIR"]) / "hypr").glob("*/.socket.sock")
                )
                if matches:
                    socket = matches[0]
                    break
                time.sleep(0.1)
            if socket is None:
                raise AssertionError(
                    "Isolated compositor did not start:\n" + log.read_text()[-8000:]
                )
            child_env["HYPRLAND_INSTANCE_SIGNATURE"] = socket.parent.name

            def ctl(*args):
                return run(["hyprctl", *args], child_env).stdout.strip()

            def evaluate(code):
                result = ctl("eval", code)
                assert result == "ok", result

            def query(code):
                return ctl("repl", code)

            # Wait for startup rather than merely socket creation.
            for _ in range(50):
                if startup.exists() and len(startup.read_text().splitlines()) == 8:
                    break
                time.sleep(0.1)
            assert ctl("configerrors") == ""
            binds = json.loads(ctl("-j", "binds"))
            # JSON keycode is zero for Lua binds in 0.56.2; plain IPC preserves code:NN.
            display_keys = [
                line.split("key: ", 1)[1].strip()
                for line in ctl("binds").splitlines()
                if line.strip().startswith("key: ")
            ]
            assert len(display_keys) == len(binds)
            keys = [
                (b["modmask"], display.split("+")[-1].strip().lower())
                for b, display in zip(binds, display_keys)
            ]
            assert len(keys) == len(set(keys)), str(
                [
                    (key, [b["description"] for b, k in zip(binds, keys) if k == key])
                    for key in set(keys)
                    if keys.count(key) > 1
                ]
            )
            assert all(b["description"] for b in binds), "Missing bind description"
            assert len(binds) == 138, f"Unexpected bind count: {len(binds)}"
            startup_before = startup.read_text()
            evaluate("desktop.toggle_gaps()")
            assert query('hl.get_config("general.gaps_out").top') == "0"
            evaluate("desktop.toggle_gaps()")
            assert query('hl.get_config("general.gaps_out").top') == "16"
            evaluate("desktop.toggle_aspect()")
            assert (
                float(query('hl.get_config("layout.single_window_aspect_ratio")[1]'))
                == 1
            )
            evaluate("desktop.toggle_aspect()")
            evaluate("desktop.pop(900, 600)")  # no window: no-op
            sockets = [
                p
                for p in Path(env["XDG_RUNTIME_DIR"]).glob("wayland-*")
                if stat.S_ISSOCK(p.stat().st_mode)
            ]
            assert len(sockets) == 1
            client_env = dict(child_env, WAYLAND_DISPLAY=str(sockets[0]))
            for class_name in ("local.terminal", "migration.second"):
                clients.append(
                    subprocess.Popen(
                        ["alacritty", "--class", class_name, "-e", "sleep", "120"],
                        env=client_env,
                        stdout=output,
                        stderr=output,
                        start_new_session=True,
                    )
                )
            for _ in range(100):
                windows = json.loads(ctl("-j", "clients"))
                if len(windows) == 2:
                    break
                time.sleep(0.1)
            assert len(windows) == 2, log.read_text()[-5000:]
            terminal = next(w for w in windows if w["class"] == "local.terminal")
            assert terminal["floating"], (
                "Floating tag must apply before floating effects"
            )
            address = terminal["address"]
            evaluate(
                'desktop.dispatch(hl.dsp.focus({ window = "address:' + address + '" }))'
            )
            # All pop operations target this window, even after changing the layout.
            evaluate("desktop.pop(900, 600, 30, 40)")
            popped = next(
                w for w in json.loads(ctl("-j", "clients")) if w["address"] == address
            )
            assert popped["floating"] and popped["pinned"] and "pop" in popped["tags"]
            assert popped["size"] == [900, 600], popped
            evaluate("desktop.pop(900, 600)")
            unpopped = next(
                w for w in json.loads(ctl("-j", "clients")) if w["address"] == address
            )
            assert not unpopped["pinned"] and "pop" not in unpopped["tags"]
            evaluate(
                'desktop.dispatch(hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))'
            )
            evaluate(
                'desktop.dispatch(hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))'
            )
            evaluate(
                "desktop.toggle_layout(); hl.exec_scheduled_prop_refresh_immediately()"
            )
            assert query("hl.get_active_workspace().tiled_layout") == "scrolling"
            evaluate(
                "desktop.toggle_layout(); hl.exec_scheduled_prop_refresh_immediately()"
            )
            assert query("hl.get_active_workspace().tiled_layout") == "dwindle"
            evaluate(
                "desktop.dispatch(hl.dsp.window.move({ workspace = 3, follow = false }))"
            )
            assert query("hl.get_active_workspace().id") != "3"
            evaluate("desktop.dispatch(hl.dsp.focus({ workspace = 3 }))")
            assert query("hl.get_active_workspace().id") == "3"
            evaluate("desktop.dispatch(hl.dsp.group.toggle())")
            evaluate("desktop.dispatch(hl.dsp.group.toggle())")
            # Helpers use this isolated compositor's signature too.
            menu = run(["menu-keybindings", "--print"], child_env).stdout
            assert "Switch to workspace 1" in menu and "SUPER CTRL ALT" in menu
            # Parent tiling controls a nested output's dimensions and may reject fractional
            # scales. A fixed headless output tests scaling independent of that geometry.
            ctl("output", "create", "headless", "migration-test")
            evaluate(
                'desktop.monitor({ output = "migration-test", mode = "1920x1080@60", position = "0x0", scale = 1 }); hl.exec_scheduled_prop_refresh_immediately()'
            )
            evaluate('desktop.dispatch(hl.dsp.focus({ monitor = "migration-test" }))')
            if float(query("hl.get_active_monitor().width")) == 0:
                print(
                    "SKIP physical scaling: nested headless backend did not commit an output mode (0x0)",
                    flush=True,
                )
            else:
                evaluate("desktop.cycle_scale()")
                for _ in range(30):
                    if abs(float(query("hl.get_active_monitor().scale")) - 1.6) < 0.01:
                        break
                    time.sleep(0.1)
                assert abs(float(query("hl.get_active_monitor().scale")) - 1.6) < 0.01
            ctl("output", "remove", "migration-test")
            print(
                "test windows: float/tag, pop/pin/size, opacity dispatch, layouts, silent move, focus/group and menu: passed",
                flush=True,
            )
            for _ in range(3):
                ctl("reload")
                assert ctl("configerrors") == ""
                assert len(json.loads(ctl("-j", "binds"))) == len(binds)
                assert startup.read_text() == startup_before
            run(["theme-set", "nord"], theme_effect_stubs(child_env, real_reload=True))
            ctl("reload")
            assert query('hl.get_config("general.gaps_out").top') == "10"
            assert startup.read_text() == startup_before
            print(
                "isolated compositor, unique binds, gaps/aspect, theme + repeated reload: passed",
                flush=True,
            )
        finally:
            for client in clients:
                if client.poll() is None:
                    os.killpg(client.pid, signal.SIGTERM)
                try:
                    client.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(client.pid, signal.SIGKILL)
                    client.wait()

            # Hyprland can create its own process group; killing dbus-run-session's
            # group alone does not necessarily terminate the compositor child.
            def compositor_pids():
                matches = []
                for entry in Path("/proc").iterdir():
                    if not entry.name.isdigit():
                        continue
                    try:
                        argv = [
                            part.decode()
                            for part in (entry / "cmdline").read_bytes().split(b"\0")
                            if part
                        ]
                        if (
                            argv
                            and argv[0].endswith("/Hyprland")
                            and "-c" in argv
                            and argv[argv.index("-c") + 1] == str(wrapper)
                        ):
                            matches.append(int(entry.name))
                    except (FileNotFoundError, PermissionError, ProcessLookupError):
                        continue
                return matches

            for pid in compositor_pids():
                try:
                    os.kill(pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
            deadline = time.monotonic() + 5
            while compositor_pids() and time.monotonic() < deadline:
                time.sleep(0.1)
            for pid in compositor_pids():
                try:
                    os.kill(pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--integration", action="store_true")
    args = parser.parse_args()
    parent = os.environ.get("WAYLAND_DISPLAY", "")
    if parent and not parent.startswith("/"):
        parent = str(Path(os.environ["XDG_RUNTIME_DIR"]) / parent)
    with tempfile.TemporaryDirectory(prefix="hc-") as directory:
        env, root, config = setup(Path(directory))
        static_checks(env, root, config)
        if args.integration:
            assert parent, "Integration requires a parent Wayland compositor"
            integration(env, root, config, parent)


if __name__ == "__main__":
    main()
