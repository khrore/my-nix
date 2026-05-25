import type {
  ExtensionAPI,
  ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";

const COMMAND_TIMEOUT_MS = 10_000;
const AGENT_TIMEOUT_MS = 60_000;
const MAX_DIFF_CHARS = 80_000;
const DEFAULT_THINKING_LEVEL = "minimal";
const COMMIT_STATUS_KEY = "commit-agent";

const COMMIT_MESSAGE_SYSTEM_PROMPT = `You write git commit subjects.
Return exactly one Conventional Commit subject line and nothing else.`;

const COMMIT_MESSAGE_PROMPT = `Write an informative Conventional Commit subject for the staged changes.

Rules:
- Return one line only: type(scope): subject or type: subject.
- Keep it under 72 characters when practical.
- Prefer specific behavior/configuration names over generic file counts.
- Do not use the feat type or the pi scope.
- Prefer chore, fix, refactor, docs, test, perf, or ci.
- Use the provided staged diff only.`;

interface GitResult {
  code: number | null | undefined;
  output: string;
}

interface ParsedArgs {
  message?: string;
  shouldStageAll: boolean;
}

type CommitCommandContext = Pick<ExtensionCommandContext, "hasUI" | "ui">;

const notify = (
  ctx: CommitCommandContext,
  message: string,
  type: "info" | "warning" | "error" = "info",
) => {
  try {
    if (ctx.hasUI) ctx.ui.notify(message, type);
  } catch {
    // Ignore notifications after the extension runtime has been replaced.
  }
};

const setCommitStatus = (
  ctx: CommitCommandContext,
  status: string | undefined,
) => {
  try {
    if (ctx.hasUI) ctx.ui.setStatus(COMMIT_STATUS_KEY, status);
  } catch {
    // Ignore status updates after the extension runtime has been replaced.
  }
};

const runGit = async (
  pi: ExtensionAPI,
  args: string[],
  signal?: AbortSignal,
): Promise<GitResult> => {
  const result = await pi.exec("git", args, {
    signal,
    timeout: COMMAND_TIMEOUT_MS,
  });
  const output = [result.stdout, result.stderr].filter(Boolean).join("\n");

  return {
    code: result.code,
    output: output.replace(/\s+$/, ""),
  };
};

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

const parseArgs = (args: string): ParsedArgs => {
  const trimmed = args.trim();
  if (!trimmed) return { shouldStageAll: false };

  const tokens = trimmed.split(/\s+/);
  const shouldStageAll = tokens.includes("--all") || tokens.includes("-a");
  const message = tokens
    .filter((token) => token !== "--all" && token !== "-a")
    .join(" ")
    .trim();

  return {
    shouldStageAll,
    message: message || undefined,
  };
};

const getStatusLines = async (pi: ExtensionAPI, signal?: AbortSignal) => {
  const status = await runGit(pi, ["status", "--short"], signal);
  if (status.code !== 0) {
    throw new Error(status.output || "git status failed");
  }

  return status.output.split("\n").filter(Boolean);
};

const getStagedStatusLines = (statusLines: string[]) => {
  return statusLines.filter((line) => {
    const indexStatus = line[0];
    return indexStatus !== " " && indexStatus !== "?";
  });
};

const extractPath = (statusLine: string) => {
  const path = statusLine.slice(3).trim();
  const renameSeparator = " -> ";
  if (path.includes(renameSeparator)) {
    return path.split(renameSeparator).at(-1) ?? path;
  }

  return path;
};

const stripExtension = (fileName: string) => {
  const withoutDirectory = fileName.split("/").at(-1) ?? fileName;
  return withoutDirectory.replace(/\.[^.]+$/, "");
};

const getParentDirectory = (path: string) => {
  return path.split("/").slice(0, -1).at(-1);
};

const describePath = (path: string) => {
  const label = stripExtension(path);

  if (path.includes("/extensions/")) return `${label} extension`;
  if (path.endsWith(".nix")) return `${label} module`;
  if (path.endsWith(".md")) return `${label} documentation`;
  if (path.endsWith(".json") || path.endsWith(".jsonc")) {
    return `${label} config`;
  }

  const parent = getParentDirectory(path);
  if (label === "default" && parent) return `${parent} configuration`;

  return label;
};

const inferScope = (paths: string[]) => {
  if (paths.length === 0) return undefined;

  const firstPath = paths[0];
  if (paths.every((path) => path.startsWith("dotfiles/common/.pi/")))
    return "pi";
  if (paths.every((path) => path.startsWith("dotfiles/"))) return "dotfiles";
  if (paths.every((path) => path.startsWith("hosts/"))) return "hosts";
  if (paths.every((path) => path.startsWith("home/"))) return "home";
  if (paths.every((path) => path.startsWith("docs/") || path.endsWith(".md"))) {
    return "docs";
  }

  const directory = firstPath.split("/").slice(0, -1).at(-1);
  return directory && paths.every((path) => path.includes(`/${directory}/`))
    ? directory
    : undefined;
};

const inferType = (paths: string[]) => {
  if (paths.every((path) => path.endsWith(".md"))) return "docs";
  if (
    paths.some((path) => /(^|\/)(test|tests|spec|__tests__)(\/|$)/.test(path))
  ) {
    return "test";
  }
  if (
    paths.some((path) => path.endsWith(".nix") || path.includes(".config/"))
  ) {
    return "chore";
  }

  return "chore";
};

const inferAction = (statusLine: string) => {
  const indexStatus = statusLine[0];

  if (indexStatus === "A") return "add";
  if (indexStatus === "D") return "remove";
  if (indexStatus === "R") return "rename";
  if (indexStatus === "C") return "copy";

  return "update";
};

const pluralize = (
  count: number,
  singular: string,
  plural = `${singular}s`,
) => {
  return count === 1 ? singular : plural;
};

const inferSubject = (statusLines: string[]) => {
  if (statusLines.length === 0) return "update repository changes";

  const paths = statusLines.map(extractPath);
  const actions = new Set(statusLines.map(inferAction));
  const action = actions.size === 1 ? [...actions][0] : "update";

  if (paths.length === 1) return `${action} ${describePath(paths[0])}`;

  const scope = inferScope(paths);
  if (scope) {
    return `${action} ${paths.length} ${scope} ${pluralize(paths.length, "file")}`;
  }

  return `${action} ${paths.length} ${pluralize(paths.length, "file")}`;
};

const inferCommitMessage = (statusLines: string[]) => {
  const paths = statusLines.map(extractPath);
  const type = inferType(paths);
  const scope = inferScope(paths);
  const subject = inferSubject(statusLines);
  const visibleScope = scope === "pi" ? undefined : scope;

  return visibleScope
    ? `${type}(${visibleScope}): ${subject}`
    : `${type}: ${subject}`;
};

const sanitizeAgentMessage = (output: string) => {
  const withoutCodeFence = output
    .replace(/^```(?:\w+)?\s*/u, "")
    .replace(/```\s*$/u, "")
    .trim();
  const line = withoutCodeFence
    .split("\n")
    .map((value) => value.trim())
    .find(Boolean);

  return line?.replace(/^[-*]\s+/u, "").replace(/^['"]|['"]$/gu, "");
};

const getStagedSnapshot = async (pi: ExtensionAPI, signal?: AbortSignal) => {
  const [nameStatus, diffStat, diff] = await Promise.all([
    runGit(pi, ["diff", "--cached", "--name-status"], signal),
    runGit(pi, ["diff", "--cached", "--stat"], signal),
    runGit(pi, ["diff", "--cached"], signal),
  ]);

  const failedCommand = [nameStatus, diffStat, diff].find(
    (result) => result.code !== 0,
  );
  if (failedCommand) {
    throw new Error(failedCommand.output || "git diff --cached failed");
  }

  return truncate(
    [
      formatCommandOutput(
        "Staged file status",
        "git diff --cached --name-status",
        nameStatus.output,
      ),
      formatCommandOutput(
        "Staged diff stat",
        "git diff --cached --stat",
        diffStat.output,
      ),
      formatCommandOutput("Staged diff", "git diff --cached", diff.output),
    ].join("\n\n"),
    MAX_DIFF_CHARS,
  );
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
    COMMIT_MESSAGE_SYSTEM_PROMPT,
    "--no-session",
    "--no-extensions",
    "--no-skills",
    "--no-prompt-templates",
    "--no-context-files",
    "--no-themes",
    "--no-builtin-tools",
    "--offline",
    "--print",
    prompt,
  ];
};

const generateCommitMessage = async (
  pi: ExtensionAPI,
  statusLines: string[],
  signal?: AbortSignal,
) => {
  const fallbackMessage = inferCommitMessage(statusLines);
  const snapshot = await getStagedSnapshot(pi, signal);
  const prompt = `${COMMIT_MESSAGE_PROMPT}\n\nFallback if the diff is unclear: ${fallbackMessage}\n\n${snapshot}`;
  const result = await pi.exec("pi", getAgentArgs(prompt), {
    signal,
    timeout: AGENT_TIMEOUT_MS,
  });

  if (result.code !== 0) return fallbackMessage;

  return sanitizeAgentMessage(result.stdout || "") || fallbackMessage;
};

const hasStagedChanges = async (pi: ExtensionAPI, signal?: AbortSignal) => {
  const diff = await runGit(pi, ["diff", "--cached", "--quiet"], signal);
  return diff.code === 1;
};

const ensureStagedChanges = async (
  pi: ExtensionAPI,
  statusLines: string[],
  shouldStageAll: boolean,
  signal?: AbortSignal,
) => {
  const stagedLines = getStagedStatusLines(statusLines);
  if (stagedLines.length > 0) return stagedLines;

  if (!shouldStageAll) {
    throw new Error(
      "No staged changes. Run /commit --all to stage all changes, or stage files manually first.",
    );
  }

  const add = await runGit(pi, ["add", "-A"], signal);
  if (add.code !== 0) {
    throw new Error(add.output || "git add -A failed");
  }

  const nextStatusLines = await getStatusLines(pi, signal);
  const nextStagedLines = getStagedStatusLines(nextStatusLines);
  if (nextStagedLines.length === 0 || !(await hasStagedChanges(pi, signal))) {
    throw new Error("No changes to commit after staging.");
  }

  return nextStagedLines;
};

const getCommitSummary = async (pi: ExtensionAPI, signal?: AbortSignal) => {
  const summary = await runGit(
    pi,
    ["log", "-1", "--pretty=format:%h %s"],
    signal,
  );
  return summary.output || "Commit created.";
};

const runCommit = async (
  pi: ExtensionAPI,
  args: string,
  ctx: CommitCommandContext,
  signal: AbortSignal,
) => {
  try {
    const parsedArgs = parseArgs(args);
    const statusLines = await getStatusLines(pi, signal);

    if (statusLines.length === 0) {
      notify(ctx, "No changes to commit.");
      return;
    }

    const commitLines = await ensureStagedChanges(
      pi,
      statusLines,
      parsedArgs.shouldStageAll,
      signal,
    );
    if (!parsedArgs.message) {
      notify(ctx, "Generating commit message...");
    }

    const message =
      parsedArgs.message ??
      (await generateCommitMessage(pi, commitLines, signal));
    const commit = await runGit(pi, ["commit", "-m", message], signal);

    if (commit.code !== 0) {
      notify(ctx, commit.output || "git commit failed", "error");
      return;
    }

    notify(ctx, await getCommitSummary(pi, signal));
  } catch (error) {
    if (signal.aborted) return;

    const message = error instanceof Error ? error.message : String(error);
    notify(ctx, message, "error");
  }
};

export default function commitAgentExtension(pi: ExtensionAPI) {
  let activeCommit: Promise<void> | undefined;
  let activeController: AbortController | undefined;

  pi.on("session_shutdown", () => {
    activeController?.abort();
  });

  pi.registerCommand("commit", {
    description:
      "Commit staged changes; pass --all to stage everything or provide text for the commit message",
    handler: async (args, ctx) => {
      if (activeCommit) {
        notify(ctx, "Commit already running.", "warning");
        return;
      }

      const controller = new AbortController();
      activeController = controller;
      setCommitStatus(ctx, "commit: running");
      notify(ctx, "Commit started in background.");

      activeCommit = runCommit(pi, args, ctx, controller.signal).finally(() => {
        if (activeController === controller) activeController = undefined;
        activeCommit = undefined;
        setCommitStatus(ctx, undefined);
      });
    },
  });
}
