import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const COMMAND_TIMEOUT_MS = 10_000;
const AGENT_TIMEOUT_MS = 120_000;
const MAX_DIFF_CHARS = 60_000;
const DEFAULT_THINKING_LEVEL = "off";

const COMMIT_AGENT_SYSTEM_PROMPT = `You are a fast git commit helper.
Use only the provided git snapshot unless you must inspect missing details.
Create at most one commit. Reply concisely with the result.`;

const COMMIT_AGENT_PROMPT = `Create exactly one git commit for the current repository changes.

Workflow:
1. Use the provided git snapshot first; avoid re-running inspection commands unless the snapshot is insufficient.
2. If nothing is staged, stage only files relevant to this commit. Do not stage unrelated changes.
3. If there are no changes to commit, stop and report that clearly.
4. Write a concise Conventional Commit message when appropriate.
   - Do not use the \`feat\` type or the scope \`pi\` in commit subjects (for example, avoid \`feat: ...\` and \`feat(pi): ...\`).
   - Prefer another accurate type such as \`chore\`, \`fix\`, \`refactor\`, \`docs\`, or \`test\`, with a specific non-agent scope only when genuinely useful.
5. Run \`git commit -m "<message>"\`.
6. Report the commit hash and summary.

Do not amend, force-push, or create multiple commits unless explicitly requested.`;

const truncate = (value: string, maxChars: number) => {
  if (value.length <= maxChars) return value;

  return `${value.slice(0, maxChars)}\n\n[truncated ${value.length - maxChars} character(s)]`;
};

const formatCommandOutput = (
  label: string,
  command: string,
  output: string,
) => {
  const body = output.trim() || "(no output)";
  return `## ${label}\n\`\`\`console\n$ ${command}\n${body}\n\`\`\``;
};

const runGit = async (pi: ExtensionAPI, args: string[]) => {
  const result = await pi.exec("git", args, { timeout: COMMAND_TIMEOUT_MS });
  const output = [result.stdout, result.stderr].filter(Boolean).join("\n");

  return {
    code: result.code,
    output: output.trim(),
  };
};

const getGitSnapshot = async (pi: ExtensionAPI) => {
  const status = await runGit(pi, ["status", "--short"]);

  if (status.code !== 0) {
    return {
      hasChanges: true,
      text: formatCommandOutput(
        "Git status failed",
        "git status --short",
        status.output,
      ),
    };
  }

  if (!status.output.trim()) {
    return {
      hasChanges: false,
      text: formatCommandOutput(
        "Git status",
        "git status --short",
        status.output,
      ),
    };
  }

  const [cachedDiff, unstagedDiff] = await Promise.all([
    runGit(pi, ["diff", "--cached"]),
    runGit(pi, ["diff"]),
  ]);

  const rawSnapshot = [
    formatCommandOutput("Git status", "git status --short", status.output),
    formatCommandOutput("Staged diff", "git diff --cached", cachedDiff.output),
    formatCommandOutput("Unstaged diff", "git diff", unstagedDiff.output),
  ].join("\n\n");

  return {
    hasChanges: true,
    text: truncate(rawSnapshot, MAX_DIFF_CHARS),
  };
};

const getAgentArgs = (prompt: string) => {
  const provider = process.env.PI_COMMIT_AGENT_PROVIDER?.trim();
  const model = process.env.PI_COMMIT_AGENT_MODEL?.trim();
  const thinking =
    process.env.PI_COMMIT_AGENT_THINKING?.trim() || DEFAULT_THINKING_LEVEL;

  return [
    ...(provider ? ["--provider", provider] : []),
    ...(model ? ["--model", model] : []),
    "--thinking",
    thinking,
    "--system-prompt",
    COMMIT_AGENT_SYSTEM_PROMPT,
    "--no-session",
    "--no-extensions",
    "--no-skills",
    "--no-prompt-templates",
    "--no-context-files",
    "--no-themes",
    "--offline",
    "--tools",
    "bash",
    "--print",
    prompt,
  ];
};

export default function commitAgentExtension(pi: ExtensionAPI) {
  pi.registerCommand("commit", {
    description: "Create a commit in an isolated ephemeral pi subprocess",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      const instructions = args.trim();
      const snapshot = await getGitSnapshot(pi);

      if (!snapshot.hasChanges) {
        ctx.ui.notify("No changes to commit.", "info");
        return;
      }

      const prompt = [
        COMMIT_AGENT_PROMPT,
        instructions ? `User instructions: ${instructions}` : undefined,
        "Use this pre-collected git snapshot:",
        snapshot.text,
      ]
        .filter(Boolean)
        .join("\n\n");

      ctx.ui.notify("Starting fast isolated commit agent...", "info");

      const result = await pi.exec("pi", getAgentArgs(prompt), {
        timeout: AGENT_TIMEOUT_MS,
      });

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
