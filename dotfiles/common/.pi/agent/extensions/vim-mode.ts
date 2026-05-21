import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Mode = "normal" | "insert" | "visual" | "operator-pending" | "text-object-pending" | "replace-pending";
type Operator = "d" | "c" | "y";
type Pos = { line: number; col: number };
type Range = { start: Pos; end: Pos; linewise?: boolean; inclusive?: boolean };

type EditorState = { lines: string[]; cursorLine: number; cursorCol: number };

const clamp = (n: number, min: number, max: number) => Math.max(min, Math.min(max, n));
const isWs = (ch: string | undefined) => ch === undefined || /\s/.test(ch);
const isWord = (ch: string | undefined) => ch !== undefined && /[A-Za-z0-9_]/.test(ch);

class VimEditor extends CustomEditor {
	private mode: Mode = "insert";
	private operator: Operator | null = null;
	private operatorStart: Pos | null = null;
	private opCount = 1;
	private count = "";
	private register = "";
	private registerLinewise = false;
	private visualStart: Pos | null = null;
	private visualLine = false;
	private pendingG = false;
	private pendingTextObjectKind: "i" | "a" | null = null;
	private lastChange: (() => void) | null = null;
	private pendingInsertRepeat: { linewise: boolean; lineCount: number; charLen: number; insertStartOffset: number; beforeInsertText: string } | null = null;

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			if (this.mode !== "normal" || this.operator || this.count) {
				if (this.mode === "insert") this.finalizeInsertRepeat();
				this.toNormal();
				return;
			}
			super.handleInput(data);
			return;
		}

		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		if (this.mode === "replace-pending") {
			this.replaceChar(data);
			this.toNormal();
			return;
		}

		if (this.mode === "text-object-pending") {
			this.finishTextObject(data);
			return;
		}

		if (this.mode === "operator-pending") {
			this.handleOperatorPending(data);
			return;
		}

		if (this.mode === "visual") {
			this.handleVisual(data);
			return;
		}

		this.handleNormal(data);
	}

	private handleNormal(key: string): void {
		if (this.acceptCount(key)) return;

		switch (key) {
			case "h": case "j": case "k": case "l": case "w": case "W": case "e": case "E": case "b": case "B": case "0": case "^": case "$":
				this.move(key, this.takeCount()); return;
			case "g": this.mode = "operator-pending"; this.operator = null; this.pendingG = true; return;
			case "G": this.gotoLine(this.takeCountOrLast()); return;
			case "i": this.mode = "insert"; this.clearCount(); return;
			case "a": this.move("l", 1); this.mode = "insert"; this.clearCount(); return;
			case "I": this.move("^", 1); this.mode = "insert"; this.clearCount(); return;
			case "A": this.move("$", 1); this.mode = "insert"; this.clearCount(); return;
			case "o": this.openLineBelow(); this.mode = "insert"; this.saveLastChange(() => this.openLineBelow()); return;
			case "O": this.openLineAbove(); this.mode = "insert"; this.saveLastChange(() => this.openLineAbove()); return;
			case "x": this.applyOperator("d", this.charRangeForward(this.takeCount()), false); return;
			case "X": this.applyOperator("d", this.charRangeBackward(this.takeCount()), false); return;
			case "s": this.applyOperator("c", this.charRangeForward(this.takeCount()), true); return;
			case "S": this.applyOperator("c", this.lineRange(this.cursor(), this.takeCount()), true); return;
			case "D": this.applyOperator("d", this.motionRange("$", 1), false); return;
			case "C": this.applyOperator("c", this.motionRange("$", 1), true); return;
			case "Y": this.applyOperator("y", this.lineRange(this.cursor(), this.takeCount()), false); return;
			case "p": this.putAfter(); return;
			case "P": this.putBefore(); return;
			case "u": super.handleInput("\x1f"); return;
			case ".": this.lastChange?.(); return;
			case "v": this.mode = "visual"; this.visualStart = this.cursor(); this.visualLine = false; this.clearCount(); return;
			case "V": this.mode = "visual"; this.visualStart = { line: this.cursor().line, col: 0 }; this.visualLine = true; this.move("$", 1); this.clearCount(); return;
			case "r": this.mode = "replace-pending"; this.clearCount(); return;
			case "d": case "c": case "y": this.startOperator(key); return;
			default: this.passControlOrIgnore(key); return;
		}
	}

	private handleOperatorPending(key: string): void {
		if (this.pendingG) {
			this.pendingG = false;
			if (key === "g") { this.gotoLine(this.takeCountOrFirst()); this.toNormal(); return; }
			this.toNormal(); return;
		}

		if (this.acceptCount(key)) return;

		if ((key === "i" || key === "a") && this.operator) {
			this.pendingTextObjectKind = key;
			this.mode = "text-object-pending";
			return;
		}

		if (this.operator && key === this.operator) {
			this.applyOperator(this.operator, this.lineRange(this.operatorStart ?? this.cursor(), this.takeCombinedCount()), this.operator === "c");
			return;
		}

		if (this.operator && this.isMotion(key)) {
			const count = key === "G" && !this.count ? this.editorState().lines.length : this.takeCombinedCount();
			this.applyOperator(this.operator, this.motionRange(key, count), this.operator === "c");
			return;
		}

		this.toNormal();
	}

	private handleVisual(key: string): void {
		if (this.acceptCount(key)) return;
		if (key === "v" || key === "V") { this.toNormal(); return; }
		if (this.isMotion(key)) { this.move(key, this.takeCount()); return; }
		if (key === "d" || key === "c" || key === "y") {
			const range = this.visualLine
				? this.lineRangeBetween(this.visualStart ?? this.cursor(), this.cursor())
				: this.rangeBetween(this.visualStart ?? this.cursor(), this.cursor(), false, true);
			this.applyOperator(key, range, key === "c");
			return;
		}
		this.passControlOrIgnore(key);
	}

	private startOperator(op: Operator): void {
		this.operator = op;
		this.operatorStart = this.cursor();
		this.opCount = this.takeCount();
		this.mode = "operator-pending";
	}

	private finishTextObject(key: string): void {
		if (!this.operator || !this.pendingTextObjectKind) { this.toNormal(); return; }
		const range = this.textObjectRange(this.pendingTextObjectKind, key);
		if (range) this.applyOperator(this.operator, range, this.operator === "c");
		else this.toNormal();
	}

	private isMotion(key: string): boolean {
		return ["h", "j", "k", "l", "w", "W", "e", "E", "b", "B", "0", "^", "$", "G"].includes(key);
	}

	private motionRange(motion: string, count: number): Range {
		const start = this.operatorStart ?? this.cursor();
		const old = this.cursor();
		this.setCursor(start);
		if (motion === "G") this.gotoLine(count); else this.move(motion, count);
		const end = this.cursor();
		this.setCursor(old);
		if (motion === "G") return this.lineRangeBetween(start, end);
		return this.rangeBetween(start, end, motion === "j" || motion === "k", motion !== "h" && motion !== "b" && motion !== "B" && motion !== "$");
	}

	private move(motion: string, count: number): void {
		const s = this.editorState();
		let { line, col } = this.cursor();
		for (let i = 0; i < Math.max(1, count); i++) {
			const text = this.text();
			switch (motion) {
				case "h": col = Math.max(0, col - 1); break;
				case "l": col = Math.min(this.line(line).length, col + 1); break;
				case "j": line = Math.min(s.lines.length - 1, line + 1); col = Math.min(col, this.line(line).length); break;
				case "k": line = Math.max(0, line - 1); col = Math.min(col, this.line(line).length); break;
				case "0": col = 0; break;
				case "^": col = this.line(line).search(/\S/); if (col < 0) col = 0; break;
				case "$": col = this.line(line).length; break;
				case "w": case "W": ({ line, col } = this.nextWord(this.offset({ line, col }), motion === "W")); break;
				case "e": case "E": ({ line, col } = this.endWord(this.offset({ line, col }), motion === "E")); break;
				case "b": case "B": ({ line, col } = this.prevWord(this.offset({ line, col }), motion === "B")); break;
			}
			void text;
		}
		this.setCursor({ line, col });
		this.clearCount();
	}

	private applyOperator(op: Operator, range: Range, enterInsert: boolean): void {
		const normalized = this.normalizeRange(range);
		const selected = this.sliceRange(normalized);
		if (op === "y") {
			this.register = selected;
			this.registerLinewise = !!normalized.linewise;
			this.toNormal();
			return;
		}
		this.register = selected;
		this.registerLinewise = !!normalized.linewise;
		if (!enterInsert) this.saveRepeat(normalized, "");
		this.replaceRange(normalized, "");
		this.toNormal();
		if (enterInsert) {
			this.mode = "insert";
			this.pendingInsertRepeat = {
				linewise: !!normalized.linewise,
				lineCount: normalized.end.line - normalized.start.line + 1,
				charLen: Math.max(0, this.offset(normalized.end) - this.offset(normalized.start)),
				insertStartOffset: this.offset(this.cursor()),
				beforeInsertText: this.text(),
			};
		}
	}

	private textObjectRange(kind: "i" | "a", object: string): Range | null {
		if (object === "w" || object === "W") return this.wordObject(kind === "a", object === "W");
		const pairs: Record<string, [string, string]> = { "(": ["(", ")"], ")": ["(", ")"], "[": ["[", "]"], "]": ["[", "]"], "{": ["{", "}"], "}": ["{", "}"], "\"": ["\"", "\""], "'": ["'", "'"], "`": ["`", "`"] };
		const pair = pairs[object];
		if (!pair) return null;
		const off = this.offset(this.cursor());
		const text = this.text();
		const left = text.lastIndexOf(pair[0], off);
		const right = text.indexOf(pair[1], pair[0] === pair[1] ? off + 1 : off);
		if (left < 0 || right < 0 || right <= left) return null;
		return { start: this.pos(left + (kind === "i" ? 1 : 0)), end: this.pos(right + (kind === "i" ? 0 : 1)), inclusive: false };
	}

	private wordObject(around: boolean, big: boolean): Range {
		const text = this.text();
		let start = this.offset(this.cursor());
		let end = start;
		const same = (a?: string, b?: string) => big ? !isWs(a) && !isWs(b) : isWord(a) && isWord(b);
		while (start > 0 && same(text[start - 1], text[start])) start--;
		while (end < text.length && same(text[end], text[end + 1])) end++;
		end = Math.min(text.length, end + 1);
		if (around) while (end < text.length && /\s/.test(text[end] ?? "")) end++;
		return { start: this.pos(start), end: this.pos(end), inclusive: false };
	}

	private nextWord(off: number, big: boolean): Pos {
		const text = this.text();
		let i = Math.min(text.length, off + 1);
		while (i < text.length && (big ? !isWs(text[i]) : isWord(text[i]))) i++;
		while (i < text.length && isWs(text[i])) i++;
		return this.pos(i);
	}

	private endWord(off: number, big: boolean): Pos {
		const text = this.text();
		let i = Math.min(text.length - 1, off + 1);
		while (i < text.length && isWs(text[i])) i++;
		while (i + 1 < text.length && (big ? !isWs(text[i + 1]) : isWord(text[i + 1]))) i++;
		return this.pos(i);
	}

	private prevWord(off: number, big: boolean): Pos {
		const text = this.text();
		let i = Math.max(0, off - 1);
		while (i > 0 && isWs(text[i])) i--;
		while (i > 0 && (big ? !isWs(text[i - 1]) : isWord(text[i - 1]))) i--;
		return this.pos(i);
	}

	private replaceChar(ch: string): void {
		if (ch.length !== 1 || ch.charCodeAt(0) < 32) return;
		const pos = this.cursor();
		if (pos.col >= this.line(pos.line).length) return;
		const range = { start: pos, end: { line: pos.line, col: pos.col + 1 }, inclusive: false };
		this.replaceRange(range, ch);
	}

	private putAfter(): void { this.put(true); }
	private putBefore(): void { this.put(false); }
	private put(after: boolean): void {
		if (!this.register) return;
		if (this.registerLinewise) {
			this.putLinewise(after);
			this.toNormal();
			return;
		}
		if (after) this.move("l", 1);
		this.insertTextAtCursor(this.register);
		this.toNormal();
	}

	private putLinewise(after: boolean): void {
		const body = this.register.endsWith("\n") ? this.register.slice(0, -1) : this.register;
		const cur = this.cursor().line;
		const insertLine = after ? cur + 1 : cur;
		const text = this.text();
		const replacement = insertLine >= this.editorState().lines.length ? `\n${body}` : `${body}\n`;
		const pos = insertLine >= this.editorState().lines.length ? this.pos(text.length) : { line: insertLine, col: 0 };
		this.replaceRange({ start: pos, end: pos, inclusive: false }, replacement);
		this.setCursor({ line: Math.min(insertLine, this.editorState().lines.length - 1), col: 0 });
	}

	private openLineBelow(): void { this.move("$", 1); this.insertTextAtCursor("\n"); }
	private openLineAbove(): void { this.move("0", 1); this.insertTextAtCursor("\n"); this.move("k", 1); }

	private lineRange(start: Pos, count: number): Range {
		const last = Math.min(this.editorState().lines.length - 1, start.line + Math.max(1, count) - 1);
		return { start: { line: start.line, col: 0 }, end: { line: last, col: this.line(last).length }, linewise: true, inclusive: true };
	}

	private charRangeForward(count: number): Range {
		const pos = this.cursor();
		const lineLen = this.line(pos.line).length;
		const endCol = Math.min(lineLen, pos.col + Math.max(1, count));
		return { start: pos, end: { line: pos.line, col: endCol }, inclusive: false };
	}

	private charRangeBackward(count: number): Range {
		const pos = this.cursor();
		const startCol = Math.max(0, pos.col - Math.max(1, count));
		return { start: { line: pos.line, col: startCol }, end: pos, inclusive: false };
	}

	private lineRangeBetween(a: Pos, b: Pos): Range {
		const first = Math.min(a.line, b.line);
		const last = Math.max(a.line, b.line);
		return { start: { line: first, col: 0 }, end: { line: last, col: this.line(last).length }, linewise: true, inclusive: true };
	}

	private rangeBetween(a: Pos, b: Pos, linewise: boolean, inclusive: boolean): Range {
		return this.offset(a) <= this.offset(b) ? { start: a, end: b, linewise, inclusive } : { start: b, end: a, linewise, inclusive };
	}

	private normalizeRange(range: Range): Range {
		if (range.linewise) return range;
		const startOff = this.offset(range.start);
		let endOff = this.offset(range.end);
		if (range.inclusive && endOff >= startOff) endOff++;
		return { start: this.pos(startOff), end: this.pos(Math.min(this.text().length, endOff)), inclusive: false };
	}

	private sliceRange(range: Range): string {
		if (range.linewise) {
			return this.editorState().lines.slice(range.start.line, range.end.line + 1).join("\n") + "\n";
		}
		return this.text().slice(this.offset(range.start), this.offset(range.end));
	}

	private replaceRange(range: Range, replacement: string): void {
		const text = this.text();
		let start = this.offset(range.start);
		let end = this.offset(range.end);
		if (range.linewise) {
			start = this.offset({ line: range.start.line, col: 0 });
			end = range.end.line + 1 < this.editorState().lines.length ? this.offset({ line: range.end.line + 1, col: 0 }) : text.length;
			if (start > 0 && end === text.length) start--;
		}
		const next = text.slice(0, start) + replacement + text.slice(end);
		this.pushUndoSnapshotCompat();
		this.setRawText(next.length ? next : "");
		this.setCursor(range.linewise ? { line: Math.min(range.start.line, this.editorState().lines.length - 1), col: 0 } : this.pos(start + replacement.length));
	}

	private setRawText(text: string): void {
		const lines = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
		const s = this.editorState();
		s.lines = lines.length ? lines : [""];
		if (this.onChange) this.onChange(this.text());
	}

	private saveRepeat(range: Range, insertedText: string): void {
		const linewise = !!range.linewise;
		const lineCount = range.end.line - range.start.line + 1;
		const charLen = Math.max(0, this.offset(range.end) - this.offset(range.start));
		this.saveLastChange(() => {
			const cur = this.cursor();
			const repeatRange = linewise
				? this.lineRange(cur, lineCount)
				: { start: cur, end: this.pos(this.offset(cur) + charLen), inclusive: false };
			this.register = this.sliceRange(repeatRange);
			this.registerLinewise = linewise;
			this.replaceRange(repeatRange, insertedText);
			this.toNormal();
		});
	}

	private finalizeInsertRepeat(): void {
		const pending = this.pendingInsertRepeat;
		if (!pending) return;
		this.pendingInsertRepeat = null;
		const after = this.text();
		const cursorOff = this.offset(this.cursor());
		const prefix = pending.beforeInsertText.slice(0, pending.insertStartOffset);
		const suffix = pending.beforeInsertText.slice(pending.insertStartOffset);
		if (!after.startsWith(prefix) || !after.endsWith(suffix) || cursorOff < pending.insertStartOffset) return;
		const insertedText = after.slice(pending.insertStartOffset, cursorOff);
		this.saveLastChange(() => {
			const cur = this.cursor();
			const repeatRange = pending.linewise
				? this.lineRange(cur, pending.lineCount)
				: { start: cur, end: this.pos(this.offset(cur) + pending.charLen), inclusive: false };
			this.register = this.sliceRange(repeatRange);
			this.registerLinewise = pending.linewise;
			this.replaceRange(repeatRange, insertedText);
			this.toNormal();
		});
	}

	private gotoLine(line: number): void { this.setCursor({ line: clamp(line - 1, 0, this.editorState().lines.length - 1), col: 0 }); this.clearCount(); }
	private takeCount(): number { const n = this.count ? Number(this.count) : 1; this.clearCount(); return n; }
	private takeCombinedCount(): number { const motion = this.count ? Number(this.count) : 1; this.clearCount(); return this.opCount * motion; }
	private takeCountOrFirst(): number { const n = this.count ? Number(this.count) : 1; this.clearCount(); return n; }
	private takeCountOrLast(): number { const n = this.count ? Number(this.count) : this.editorState().lines.length; this.clearCount(); return n; }
	private acceptCount(key: string): boolean { if (/^[1-9]$/.test(key) || (this.count && key === "0")) { this.count += key; return true; } return false; }
	private clearCount(): void { this.count = ""; }
	private toNormal(): void { this.mode = "normal"; this.operator = null; this.operatorStart = null; this.pendingG = false; this.pendingTextObjectKind = null; this.pendingInsertRepeat = null; this.count = ""; this.opCount = 1; this.visualStart = null; this.visualLine = false; }
	private saveLastChange(fn: () => void): void { this.lastChange = fn; }
	private pushUndoSnapshotCompat(): void { (this as unknown as { pushUndoSnapshot?: () => void }).pushUndoSnapshot?.(); }

	private editorState(): EditorState { return (this as unknown as { state: EditorState }).state; }
	private cursor(): Pos { const s = this.editorState(); return { line: s.cursorLine, col: s.cursorCol }; }
	private line(line: number): string { return this.editorState().lines[line] ?? ""; }
	private text(): string { return this.editorState().lines.join("\n"); }
	private setCursor(pos: Pos): void { const s = this.editorState(); s.cursorLine = clamp(pos.line, 0, s.lines.length - 1); s.cursorCol = clamp(pos.col, 0, this.line(s.cursorLine).length); }
	private offset(pos: Pos): number { let off = 0; for (let i = 0; i < pos.line; i++) off += this.line(i).length + 1; return off + pos.col; }
	private pos(offset: number): Pos { let rest = clamp(offset, 0, this.text().length); const lines = this.editorState().lines; for (let line = 0; line < lines.length; line++) { const len = lines[line]!.length; if (rest <= len) return { line, col: rest }; rest -= len + 1; } return { line: lines.length - 1, col: lines.at(-1)?.length ?? 0 }; }
	private passControlOrIgnore(data: string): void { if (data.length === 1 && data.charCodeAt(0) >= 32) return; super.handleInput(data); }

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;
		const pending = this.mode === "operator-pending" && this.operator ? ` ${this.operator}` : this.count ? ` ${this.count}` : "";
		const label = ` ${this.mode.toUpperCase()}${pending} `;
		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= label.length) lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + label;
		return lines;
	}
}

export default function vimModeExtension(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, keybindings) => new VimEditor(tui, theme, keybindings));
	});
}
