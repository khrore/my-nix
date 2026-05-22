import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const COMMIT_AGENT_PROMPT = `Create exactly one git commit for the current repository changes.

Workflow:
1. Inspect git status with \`git status --short\`.
2. Inspect staged changes with \`git diff --cached\`.
3. If nothing is staged, inspect unstaged changes with \`git diff\` and stage only files relevant to this commit. Do not stage unrelated changes.
4. If there are no changes to commit, stop and report that clearly.
5. Write a concise Conventional Commit message when appropriate.
   - Do not use the \`feat\` type or the scope \`pi\` in commit subjects (for example, avoid \`feat: ...\` and \`feat(pi): ...\`).
   - Prefer another accurate type such as \`chore\`, \`fix\`, \`refactor\`, \`docs\`, or \`test\`, with a specific non-agent scope only when genuinely useful.
6. Run \`git commit -m "<message>"\`.
7. Report the commit hash and summary.

Do not amend, force-push, or create multiple commits unless explicitly requested.`;

export default function commitAgentExtension(pi: ExtensionAPI) {
	pi.registerCommand("commit", {
		description: "Create a commit in an isolated ephemeral pi subprocess",
		handler: async (args, ctx) => {
			await ctx.waitForIdle();

			const instructions = args.trim();
			const prompt = instructions
				? `${COMMIT_AGENT_PROMPT}\n\nUser instructions: ${instructions}`
				: COMMIT_AGENT_PROMPT;

			ctx.ui.notify("Starting isolated commit agent...", "info");

			const result = await pi.exec(
				"pi",
				[
					"--no-session",
					"--no-extensions",
					"--no-skills",
					"--no-prompt-templates",
					"--tools",
					"bash",
					"--print",
					prompt,
				],
				{ timeout: 120_000 },
			);

			const stdout = result.stdout?.trim();
			const stderr = result.stderr?.trim();

			if (result.code === 0) {
				ctx.ui.notify(stdout || "Commit agent finished.", "info");
				return;
			}

			ctx.ui.notify(
				`Commit agent failed with exit code ${result.code ?? "unknown"}.\n${stderr || stdout || "No output."}`,
				"error",
			);
		},
	});
}
