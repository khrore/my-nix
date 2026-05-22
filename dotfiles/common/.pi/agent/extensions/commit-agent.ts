import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const COMMAND_TIMEOUT_MS = 10_000;

interface GitResult {
  code: number | null | undefined;
  output: string;
}

interface ParsedArgs {
  message?: string;
  shouldStageAll: boolean;
}

const runGit = async (pi: ExtensionAPI, args: string[]): Promise<GitResult> => {
  const result = await pi.exec("git", args, { timeout: COMMAND_TIMEOUT_MS });
  const output = [result.stdout, result.stderr].filter(Boolean).join("\n");

  return {
    code: result.code,
    output: output.trim(),
  };
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

const getStatusLines = async (pi: ExtensionAPI) => {
  const status = await runGit(pi, ["status", "--short"]);
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

const inferSubject = (paths: string[]) => {
  if (paths.length === 0) return "update repository changes";
  if (paths.length === 1) return `update ${stripExtension(paths[0])}`;

  const scope = inferScope(paths);
  if (scope) return `update ${scope} configuration`;

  return `update ${paths.length} files`;
};

const inferCommitMessage = (statusLines: string[]) => {
  const paths = statusLines.map(extractPath);
  const type = inferType(paths);
  const scope = inferScope(paths);
  const subject = inferSubject(paths);
  const visibleScope = scope === "pi" ? undefined : scope;

  return visibleScope
    ? `${type}(${visibleScope}): ${subject}`
    : `${type}: ${subject}`;
};

const hasStagedChanges = async (pi: ExtensionAPI) => {
  const diff = await runGit(pi, ["diff", "--cached", "--quiet"]);
  return diff.code === 1;
};

const ensureStagedChanges = async (
  pi: ExtensionAPI,
  statusLines: string[],
  shouldStageAll: boolean,
) => {
  const stagedLines = getStagedStatusLines(statusLines);
  if (stagedLines.length > 0) return stagedLines;

  if (!shouldStageAll) {
    throw new Error(
      "No staged changes. Run /commit --all to stage all changes, or stage files manually first.",
    );
  }

  const add = await runGit(pi, ["add", "-A"]);
  if (add.code !== 0) {
    throw new Error(add.output || "git add -A failed");
  }

  const nextStatusLines = await getStatusLines(pi);
  const nextStagedLines = getStagedStatusLines(nextStatusLines);
  if (nextStagedLines.length === 0 || !(await hasStagedChanges(pi))) {
    throw new Error("No changes to commit after staging.");
  }

  return nextStagedLines;
};

const getCommitSummary = async (pi: ExtensionAPI) => {
  const summary = await runGit(pi, ["log", "-1", "--pretty=format:%h %s"]);
  return summary.output || "Commit created.";
};

export default function commitAgentExtension(pi: ExtensionAPI) {
  pi.registerCommand("commit", {
    description: "Create a git commit quickly without launching an agent",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      try {
        const parsedArgs = parseArgs(args);
        const statusLines = await getStatusLines(pi);

        if (statusLines.length === 0) {
          ctx.ui.notify("No changes to commit.", "info");
          return;
        }

        const commitLines = await ensureStagedChanges(
          pi,
          statusLines,
          parsedArgs.shouldStageAll,
        );
        const message = parsedArgs.message ?? inferCommitMessage(commitLines);
        const commit = await runGit(pi, ["commit", "-m", message]);

        if (commit.code !== 0) {
          ctx.ui.notify(commit.output || "git commit failed", "error");
          return;
        }

        ctx.ui.notify(await getCommitSummary(pi), "info");
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(message, "error");
      }
    },
  });
}
