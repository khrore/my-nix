import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type VimMode = "normal" | "insert" | "visual";
type Operator = "d" | "c";

const KEY = {
	left: "\x1b[D",
	down: "\x1b[B",
	up: "\x1b[A",
	right: "\x1b[C",
	lineStart: "\x01",
	lineEnd: "\x05",
	deleteForward: "\x1b[3~",
	deleteWordForward: "\x1bd",
	deleteWordBackward: "\x17",
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
			if (this.mode !== "normal" || this.pending) {
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
			if (this.handlePending(combo, data)) return;
		}

		if (this.mode === "visual") {
			if (this.handleVisualKey(data)) return;
			this.ignorePrintable(data);
			return;
		}

		if (this.handleNormalKey(data)) return;
		this.ignorePrintable(data);
	}

	private handlePending(combo: string, data: string): boolean {
		if (combo === "r" + data && data.length === 1 && data.charCodeAt(0) >= 32) {
			super.handleInput(KEY.deleteForward);
			this.insertTextAtCursor(data);
			return true;
		}

		if (combo === "gg") {
			// Best available approximation in pi's single prompt editor.
			super.handleInput(KEY.lineStart);
			return true;
		}

		if (combo === "di" || combo === "da" || combo === "ci" || combo === "ca") {
			this.pending = combo;
			return true;
		}

		if (combo === "diw" || combo === "daw") return this.deleteWordUnderCursor(false);
		if (combo === "ciw" || combo === "caw") return this.deleteWordUnderCursor(true);

		if (combo.length === 2 && (combo[0] === "d" || combo[0] === "c")) {
			return this.applyOperator(combo[0] as Operator, combo[1]!);
		}

		return false;
	}

	private applyOperator(operator: Operator, motion: string): boolean {
		const change = operator === "c";

		switch (motion) {
			case "d":
			case "c":
				if (motion !== operator) return false;
				this.deleteLine();
				if (change) this.mode = "insert";
				return true;
			case "w":
			case "e":
				this.deleteWordForward();
				if (change) this.mode = "insert";
				return true;
			case "b":
				this.deleteWordBackward();
				if (change) this.mode = "insert";
				return true;
			case "$":
				this.deleteToLineEnd();
				if (change) this.mode = "insert";
				return true;
			case "0":
			case "^":
				this.deleteToLineStart();
				if (change) this.mode = "insert";
				return true;
			case "h":
				this.deleteBackwardChar();
				if (change) this.mode = "insert";
				return true;
			case "l":
				this.deleteForwardChar();
				if (change) this.mode = "insert";
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
			case "e":
				super.handleInput(KEY.wordForward);
				return true;
			case "b":
				super.handleInput(KEY.wordBack);
				return true;
			case "0":
			case "^":
				// Pi's editor has line-start, not first-non-blank, so ^ maps to line start.
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
				this.deleteForwardChar();
				return true;
			case "X":
				this.deleteBackwardChar();
				return true;
			case "s":
				this.deleteForwardChar();
				this.mode = "insert";
				return true;
			case "S":
				this.deleteLine();
				this.mode = "insert";
				return true;
			case "D":
				this.deleteToLineEnd();
				return true;
			case "C":
				this.deleteToLineEnd();
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
			case "r":
			case "g":
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

	private deleteForwardChar(): void {
		super.handleInput(KEY.deleteForward);
	}

	private deleteBackwardChar(): void {
		super.handleInput(KEY.backspace);
	}

	private deleteWordForward(): void {
		super.handleInput(KEY.deleteWordForward);
	}

	private deleteWordBackward(): void {
		super.handleInput(KEY.deleteWordBackward);
	}

	private deleteToLineStart(): void {
		super.handleInput(KEY.deleteToLineStart);
	}

	private deleteToLineEnd(): void {
		super.handleInput(KEY.deleteToLineEnd);
	}

	private deleteLine(): void {
		super.handleInput(KEY.lineStart);
		super.handleInput(KEY.deleteToLineEnd);
		super.handleInput(KEY.deleteForward);
	}

	private deleteWordUnderCursor(change: boolean): boolean {
		// Approximation for Vim text objects: go to previous word boundary, then delete word.
		super.handleInput(KEY.wordBack);
		this.deleteWordForward();
		if (change) this.mode = "insert";
		return true;
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
