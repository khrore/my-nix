import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { extname, join } from "node:path";

const RULES_ROOT = join(homedir(), ".agents", "rules");
const PROJECT_CONFIG = join(".pi", "language-rules.json");
const MAX_RULE_BYTES = 40 * 1024;
const MAX_SCAN_DEPTH = 3;
const MAX_SCAN_FILES = 2_000;

const SKIP_DIRS = new Set([
  ".git",
  "node_modules",
  "target",
  "dist",
  "build",
  "result",
  ".result",
  ".direnv",
  ".venv",
  "venv",
  "__pycache__",
]);

const AUTO_LANGUAGE_IDS = new Set([
  "cpp",
  "csharp",
  "dart",
  "golang",
  "java",
  "kotlin",
  "nix",
  "perl",
  "php",
  "python",
  "rust",
  "swift",
  "typescript",
  "web",
]);

interface RulesConfig {
  include?: string[];
  exclude?: string[];
}

interface LoadedRules {
  names: string[];
  text: string;
  truncated: boolean;
}

export default function languageRules(pi: ExtensionAPI) {
  let notifiedForSession = false;

  pi.on("session_start", () => {
    notifiedForSession = false;
  });

  pi.on("before_agent_start", async (event, ctx) => {
    const loaded = loadProjectRules(ctx.cwd);
    if (!loaded.text.trim()) return;

    if (!notifiedForSession) {
      notifiedForSession = true;
      if (ctx.hasUI) {
        const suffix = loaded.truncated ? " (truncated)" : "";
        ctx.ui.notify(`Loaded language rules: ${loaded.names.join(", ")}${suffix}`, "info");
      }
    }

    return {
      systemPrompt: `${event.systemPrompt}\n\n# Project Language Rules\n\n${loaded.text}`,
    };
  });
}

function loadProjectRules(cwd: string): LoadedRules {
  const config = readProjectConfig(cwd);
  const detected = detectLanguages(cwd);
  const include = normalizeRuleNames(config.include ?? []);
  const exclude = new Set(normalizeRuleNames(config.exclude ?? []));

  const names = unique([
    "common",
    ...include.filter((name) => name !== "common"),
    ...[...detected].sort(),
  ]).filter((name) => name === "common" || !exclude.has(name));

  const sections: string[] = [];
  const loadedNames: string[] = [];

  for (const name of names) {
    const content = loadRuleDir(join(RULES_ROOT, name), name);
    if (!content) continue;
    loadedNames.push(name);
    sections.push(content);
  }

  const { text, truncated } = truncateSectionsUtf8(sections, MAX_RULE_BYTES);
  return { names: loadedNames, text, truncated };
}

function readProjectConfig(cwd: string): RulesConfig {
  const path = join(cwd, PROJECT_CONFIG);
  if (!existsSync(path)) return {};

  try {
    const parsed = JSON.parse(readFileSync(path, "utf-8"));
    return {
      include: Array.isArray(parsed.include) ? parsed.include.filter((v: unknown) => typeof v === "string") : [],
      exclude: Array.isArray(parsed.exclude) ? parsed.exclude.filter((v: unknown) => typeof v === "string") : [],
    };
  } catch {
    return {};
  }
}

function detectLanguages(cwd: string): Set<string> {
  const languages = new Set<string>();

  addMarkers(cwd, languages);
  scanSourceFiles(cwd, languages);

  // zh is intentionally explicit-only: it is a human-language preference, not a project language.
  for (const language of [...languages]) {
    if (!AUTO_LANGUAGE_IDS.has(language)) languages.delete(language);
  }

  return languages;
}

function addMarkers(cwd: string, languages: Set<string>) {
  if (hasFile(cwd, "flake.nix") || hasFile(cwd, "default.nix")) languages.add("nix");
  if (hasFile(cwd, "Cargo.toml") || hasFile(cwd, "Cargo.lock")) languages.add("rust");
  if (hasAnyFile(cwd, ["pyproject.toml", "requirements.txt", "uv.lock", "Pipfile", "poetry.lock"])) languages.add("python");
  if (hasFile(cwd, "package.json") || hasFile(cwd, "tsconfig.json")) languages.add("typescript");
  if (hasFile(cwd, "package.json") || hasAnyRootPrefix(cwd, ["vite.config.", "next.config."])) languages.add("web");
  if (hasAnyFile(cwd, ["go.mod", "go.sum"])) languages.add("golang");
  if (hasAnyFile(cwd, ["pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts"])) languages.add("java");
  if (hasFile(cwd, "pubspec.yaml")) languages.add("dart");
  if (hasFile(cwd, "composer.json")) languages.add("php");
  if (hasFile(cwd, "Package.swift")) languages.add("swift");
  if (hasAnyFile(cwd, ["CMakeLists.txt", "compile_commands.json"])) languages.add("cpp");
}

function scanSourceFiles(cwd: string, languages: Set<string>) {
  let scanned = 0;

  const visit = (dir: string, depth: number) => {
    if (depth > MAX_SCAN_DEPTH || scanned >= MAX_SCAN_FILES) return;

    let entries;
    try {
      entries = readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }

    for (const entry of entries) {
      if (scanned >= MAX_SCAN_FILES) return;
      if (entry.name.startsWith(".") && entry.name !== ".config") continue;

      const path = join(dir, entry.name);

      if (entry.isDirectory()) {
        if (!SKIP_DIRS.has(entry.name)) visit(path, depth + 1);
        continue;
      }

      if (!entry.isFile()) continue;
      scanned += 1;
      addLanguageForFile(entry.name, languages);
    }
  };

  visit(cwd, 0);
}

function addLanguageForFile(fileName: string, languages: Set<string>) {
  if (fileName.endsWith(".nix")) languages.add("nix");
  if (fileName.endsWith(".rs")) languages.add("rust");
  if (fileName.endsWith(".py")) languages.add("python");
  if (fileName.endsWith(".ts") || fileName.endsWith(".tsx")) languages.add("typescript");
  if (fileName.endsWith(".tsx") || fileName.endsWith(".jsx") || fileName.endsWith(".vue") || fileName.endsWith(".svelte")) languages.add("web");
  if (fileName.endsWith(".go")) languages.add("golang");
  if (fileName.endsWith(".java")) languages.add("java");
  if (fileName.endsWith(".kt") || fileName.endsWith(".kts")) languages.add("kotlin");
  if (fileName.endsWith(".dart")) languages.add("dart");
  if (fileName.endsWith(".php")) languages.add("php");
  if (fileName.endsWith(".swift")) languages.add("swift");
  if (fileName.endsWith(".pl") || fileName.endsWith(".pm")) languages.add("perl");
  if (fileName.endsWith(".cs") || fileName.endsWith(".csproj") || fileName.endsWith(".sln")) languages.add("csharp");
  if ([".c", ".cc", ".cpp", ".cxx", ".h", ".hh", ".hpp", ".hxx"].includes(extname(fileName))) languages.add("cpp");
}

function loadRuleDir(dir: string, name: string): string {
  if (!existsSync(dir)) return "";

  let files: string[];
  try {
    files = readdirSync(dir)
      .map((file) => join(dir, file))
      .filter((path) => statSync(path).isFile() && path.endsWith(".md"))
      .sort();
  } catch {
    return "";
  }

  const content = files
    .map((file) => safeRead(file).trim())
    .filter(Boolean)
    .join("\n\n");

  return content ? `## ${name}\n\n${content}` : "";
}

function hasFile(cwd: string, file: string): boolean {
  return existsSync(join(cwd, file));
}

function hasAnyFile(cwd: string, files: string[]): boolean {
  return files.some((file) => hasFile(cwd, file));
}

function hasAnyRootPrefix(cwd: string, prefixes: string[]): boolean {
  try {
    return readdirSync(cwd).some((entry) => prefixes.some((prefix) => entry.startsWith(prefix)));
  } catch {
    return false;
  }
}

function safeRead(path: string): string {
  try {
    return readFileSync(path, "utf-8");
  } catch {
    return "";
  }
}

function normalizeRuleNames(names: string[]): string[] {
  return names
    .map((name) => name.trim().toLowerCase())
    .filter((name) => /^[a-z0-9-]+$/.test(name));
}

function unique(values: string[]): string[] {
  const seen = new Set<string>();
  const result: string[] = [];
  for (const value of values) {
    if (seen.has(value)) continue;
    seen.add(value);
    result.push(value);
  }
  return result;
}

function truncateSectionsUtf8(sections: string[], maxBytes: number): { text: string; truncated: boolean } {
  const joined = sections.join("\n\n");
  if (Buffer.byteLength(joined, "utf-8") <= maxBytes) {
    return { text: joined, truncated: false };
  }

  const notice = `\n\n[Language rules truncated: exceeded ${Math.floor(maxBytes / 1024)} KB]`;
  const separatorBytes = Buffer.byteLength("\n\n", "utf-8") * Math.max(0, sections.length - 1);
  const availableBytes = Math.max(0, maxBytes - Buffer.byteLength(notice, "utf-8") - separatorBytes);
  const sectionBudget = Math.max(1, Math.floor(availableBytes / Math.max(1, sections.length)));
  const truncatedSections = sections.map((section) => truncateTextToBytes(section, sectionBudget).trimEnd());

  return {
    text: `${truncatedSections.join("\n\n").trimEnd()}${notice}`,
    truncated: true,
  };
}

function truncateTextToBytes(text: string, maxBytes: number): string {
  if (Buffer.byteLength(text, "utf-8") <= maxBytes) return text;

  let truncated = text;
  while (Buffer.byteLength(truncated, "utf-8") > maxBytes && truncated.length > 0) {
    truncated = truncated.slice(0, -1);
  }
  return truncated;
}
