import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type VimMode = "normal" | "insert" | "visual";

const KEY = {
	left: "\x1b[D",
	down: "\x1b[B",
	up: "\x1b[A",
	right: "\x1b[C",
	lineStart: "\x01",
	lineEnd: "\x05",
	deleteForward: "\x1b[3~",
	deleteToLineStart: "\x15",
	deleteToLineEnd: "\x0b",
	wordBack: "\x1bb",
	wordForward: "\x1bf",
	backspace: "\x7f",
	newline: "\n",
	undo: "\x1f",
};

class VimEditor extends CustomEditor {
	private mode: VimMode = "insert";
	private pending: string | null = null;

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			if (this.mode !== "normal") {
				this.mode = "normal";
				this.pending = null;
				return;
			}

			super.handleInput(data);
			return;
		}

		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		if (this.pending) {
			const combo = this.pending + data;
			this.pending = null;
			if (this.handleNormalCombo(combo)) return;
		}

		if (this.mode === "visual") {
			if (this.handleVisualKey(data)) return;
			this.ignorePrintable(data);
			return;
		}

		if (this.handleNormalKey(data)) return;
		this.ignorePrintable(data);
	}

	private handleNormalCombo(combo: string): boolean {
		switch (combo) {
			case "dd":
				super.handleInput(KEY.lineStart);
				super.handleInput(KEY.deleteToLineEnd);
				super.handleInput(KEY.deleteForward);
				return true;
			case "dw":
				super.handleInput(KEY.deleteForward);
				// Approximation: pi's editor exposes word-delete forward through Alt+D.
				super.handleInput("\x1bd");
				return true;
			case "cc":
				super.handleInput(KEY.lineStart);
				super.handleInput(KEY.deleteToLineEnd);
				this.mode = "insert";
				return true;
			default:
				return false;
		}
	}

	private handleNormalKey(data: string): boolean {
		switch (data) {
			case "h":
				super.handleInput(KEY.left);
				return true;
			case "j":
				super.handleInput(KEY.down);
				return true;
			case "k":
				super.handleInput(KEY.up);
				return true;
			case "l":
				super.handleInput(KEY.right);
				return true;
			case "w":
				super.handleInput(KEY.wordForward);
				return true;
			case "b":
				super.handleInput(KEY.wordBack);
				return true;
			case "0":
			case "^":
				super.handleInput(KEY.lineStart);
				return true;
			case "$":
				super.handleInput(KEY.lineEnd);
				return true;
			case "i":
				this.mode = "insert";
				return true;
			case "a":
				super.handleInput(KEY.right);
				this.mode = "insert";
				return true;
			case "I":
				super.handleInput(KEY.lineStart);
				this.mode = "insert";
				return true;
			case "A":
				super.handleInput(KEY.lineEnd);
				this.mode = "insert";
				return true;
			case "o":
				super.handleInput(KEY.lineEnd);
				super.handleInput(KEY.newline);
				this.mode = "insert";
				return true;
			case "O":
				super.handleInput(KEY.lineStart);
				super.handleInput(KEY.newline);
				super.handleInput(KEY.up);
				this.mode = "insert";
				return true;
			case "x":
				super.handleInput(KEY.deleteForward);
				return true;
			case "X":
				super.handleInput(KEY.backspace);
				return true;
			case "D":
				super.handleInput(KEY.deleteToLineEnd);
				return true;
			case "C":
				super.handleInput(KEY.deleteToLineEnd);
				this.mode = "insert";
				return true;
			case "u":
				super.handleInput(KEY.undo);
				return true;
			case "v":
				this.mode = "visual";
				return true;
			case "d":
			case "c":
				this.pending = data;
				return true;
			default:
				return false;
		}
	}

	private handleVisualKey(data: string): boolean {
		// Visual mode is modal and supports movement. Selection/yank/delete are not exposed
		// by pi's editor component yet, so v/Escape return to normal mode.
		if (data === "v") {
			this.mode = "normal";
			return true;
		}
		return this.handleNormalKey(data);
	}

	private ignorePrintable(data: string): void {
		if (data.length === 1 && data.charCodeAt(0) >= 32) return;
		super.handleInput(data);
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		const label = ` ${this.mode.toUpperCase()}${this.pending ? ` ${this.pending}` : ""} `;
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= label.length) {
			lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + label;
		}
		return lines;
	}
}

export default function vimModeExtension(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, keybindings) => new VimEditor(tui, theme, keybindings));
	});
}
