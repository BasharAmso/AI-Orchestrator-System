#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const BOLD = "\x1b[1m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const DIM = "\x1b[2m";
const RESET = "\x1b[0m";

const VERSION = require("../package.json").version;
const TEMPLATE_DIR = path.join(__dirname, "..", "template");

function log(msg) {
  console.log(msg);
}

function success(msg) {
  console.log(`${GREEN}${msg}${RESET}`);
}

function warn(msg) {
  console.log(`${YELLOW}${msg}${RESET}`);
}

function error(msg) {
  console.error(`${RED}${msg}${RESET}`);
}

/**
 * In light mode, skip agent/skill files that load from Cortex MCP.
 * Keep orchestrator.md, coach.md, REGISTRY.md, and all non-skill/agent files.
 */
function shouldSkipInLightMode(relPath) {
  const normalized = relPath.replace(/\\/g, "/");

  // Skip agent files EXCEPT orchestrator.md and coach.md
  if (normalized.startsWith(".claude/agents/")) {
    const filename = path.basename(normalized);
    if (filename !== "orchestrator.md" && filename !== "coach.md") {
      return true;
    }
  }

  // Skip skill subfolders (everything inside .claude/skills/*/)
  // Keep REGISTRY.md and meta-skills that need local file access
  if (normalized.startsWith(".claude/skills/")) {
    const rest = normalized.slice(".claude/skills/".length);
    // REGISTRY.md is at the skills root, not in a subfolder
    if (rest === "REGISTRY.md") {
      return false;
    }
    // Meta-skills that inspect local project files (can't run from Cortex)
    if (rest.startsWith("token-audit/") || rest.startsWith("skill-creator/")) {
      return false;
    }
    // Anything else in a subfolder gets skipped
    if (rest.length > 0) {
      return true;
    }
  }

  // Skip custom-skills subfolder contents
  if (normalized.startsWith("custom-skills/")) {
    const rest = normalized.slice("custom-skills/".length);
    // Keep the custom-skills directory itself, skip contents
    if (rest.length > 0) {
      return true;
    }
  }

  return false;
}

function copyDirRecursive(src, dest, stats, lightMode, templateRoot) {
  if (!fs.existsSync(src)) return;

  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (lightMode) {
      const relPath = path.relative(templateRoot, srcPath);
      if (shouldSkipInLightMode(relPath)) {
        stats.lightSkipped++;
        continue;
      }
    }

    if (entry.isDirectory()) {
      if (!fs.existsSync(destPath)) {
        fs.mkdirSync(destPath, { recursive: true });
      }
      copyDirRecursive(srcPath, destPath, stats, lightMode, templateRoot);
    } else {
      if (fs.existsSync(destPath)) {
        stats.skipped++;
      } else {
        fs.mkdirSync(path.dirname(destPath), { recursive: true });
        fs.copyFileSync(srcPath, destPath);
        stats.copied++;
      }
    }
  }
}

function copyDirForce(src, dest, stats, lightMode, templateRoot) {
  if (!fs.existsSync(src)) return;

  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (lightMode) {
      const relPath = path.relative(templateRoot, srcPath);
      if (shouldSkipInLightMode(relPath)) {
        stats.lightSkipped++;
        continue;
      }
    }

    if (entry.isDirectory()) {
      if (!fs.existsSync(destPath)) {
        fs.mkdirSync(destPath, { recursive: true });
      }
      copyDirForce(srcPath, destPath, stats, lightMode, templateRoot);
    } else {
      fs.mkdirSync(path.dirname(destPath), { recursive: true });
      fs.copyFileSync(srcPath, destPath);
      stats.copied++;
    }
  }
}

function main() {
  const args = process.argv.slice(2);

  if (args.includes("--help") || args.includes("-h")) {
    log(`
${BOLD}create-bashi-app${RESET} v${VERSION}

Set up Bashi in any project.

${BOLD}Usage:${RESET}
  cd your-project
  npx create-bashi-app              Install in current directory
  npx create-bashi-app --light      MCP-connected mode (680+ skills via Cortex)

  Starting fresh? npx create-bashi-app my-app creates a new directory.

${BOLD}Options:${RESET}
  --help, -h     Show this help message
  --version, -v  Show version number
  --force        Overwrite existing files (default: skip)
  --light        MCP-connected mode: only orchestrator + coach agents
                 on disk; all other knowledge from Cortex MCP

${BOLD}Modes:${RESET}
  Standalone (default)  12 agents, 37 skills, 20 commands, 11 hooks
                        Everything on disk. Works without any MCP server.

  Light (--light) 2 agents (orchestrator + coach), 20 commands, 11 hooks
                  Skills and other agents load from Cortex MCP on demand.
                  Requires Cortex MCP server configured.

${BOLD}What it does:${RESET}
  1. Copies the .claude/ framework (commands, hooks, rules, state)
  2. Standalone: also copies all agents and skills
  3. Light: only orchestrator + coach agents, skills from MCP
  4. Does NOT overwrite existing files unless --force is used

${BOLD}After install:${RESET}
  Open the project in VS Code with Claude Code and run /start
`);
    process.exit(0);
  }

  if (args.includes("--version") || args.includes("-v")) {
    log(VERSION);
    process.exit(0);
  }

  const force = args.includes("--force");
  const light = args.includes("--light");
  const dirArg = args.find((a) => !a.startsWith("-"));
  const targetDir = dirArg ? path.resolve(dirArg) : process.cwd();

  log("");
  log(
    `${BOLD}Bashi${RESET} v${VERSION}`
  );
  if (light) {
    log(
      `${DIM}MCP-connected mode | 2 agents (local) | 20 commands | 11 hooks${RESET}`
    );
  } else {
    log(
      `${DIM}12 agents | 37 skills | 20 commands | 11 safety hooks${RESET}`
    );
  }
  log("");

  // Create target directory if it doesn't exist
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
    log(`Created directory: ${dirArg}`);
  }

  // Check if .claude already exists
  const claudeDir = path.join(targetDir, ".claude");
  if (fs.existsSync(claudeDir) && !force) {
    warn(
      "A .claude/ directory already exists in this project."
    );
    warn(
      "Use --force to overwrite, or remove it first."
    );
    log("");
    process.exit(1);
  }

  // Verify template exists
  if (!fs.existsSync(TEMPLATE_DIR)) {
    error("Template directory not found. Package may be corrupted.");
    process.exit(1);
  }

  // Copy template
  if (light) {
    log("Installing framework (light mode)...");
  } else {
    log("Installing framework...");
  }
  log("");

  const stats = { copied: 0, skipped: 0, lightSkipped: 0 };

  if (force && fs.existsSync(claudeDir)) {
    copyDirForce(TEMPLATE_DIR, targetDir, stats, light, TEMPLATE_DIR);
  } else {
    copyDirRecursive(TEMPLATE_DIR, targetDir, stats, light, TEMPLATE_DIR);
  }

  // Initialize git if needed
  const gitDir = path.join(targetDir, ".git");
  if (!fs.existsSync(gitDir)) {
    log(`${DIM}Initializing git repository...${RESET}`);
    const { execSync } = require("child_process");
    try {
      execSync("git init", { cwd: targetDir, stdio: "pipe" });
      log(`${DIM}Git repository initialized.${RESET}`);
    } catch {
      warn("Could not initialize git. You may need to run 'git init' manually.");
    }
  }

  log(`  ${GREEN}Copied:${RESET}  ${stats.copied} files`);
  if (stats.skipped > 0) {
    log(`  ${YELLOW}Skipped:${RESET} ${stats.skipped} files (already exist)`);
  }
  if (stats.lightSkipped > 0) {
    log(`  ${DIM}Excluded:${RESET} ${stats.lightSkipped} files (loaded from MCP)`);
  }
  log("");

  success("Framework installed successfully!");
  log("");
  log(`${BOLD}Next steps:${RESET}`);
  if (dirArg) {
    log(`  1. cd ${dirArg}`);
    log(`  2. Open in VS Code with Claude Code`);
    log(`  3. Run /start`);
    log(`     ${DIM}First time? It'll ask about you to personalize the experience.${RESET}`);
  } else {
    log(`  1. Open this project in VS Code with Claude Code`);
    log(`  2. Run /start`);
    log(`     ${DIM}First time? It'll ask about you to personalize the experience.${RESET}`);
  }

  if (light) {
    log("");
    log(`${YELLOW}${BOLD}Cortex MCP Setup Required${RESET}`);
    log("");
    log(`  This install uses MCP-connected mode. Skills and agents`);
    log(`  load on-demand from Cortex MCP. To configure:`);
    log("");
    log(`  Add to your Claude Code MCP settings:`);
    log(`    Server name: ${BOLD}cortex${RESET}`);
    log(`    Command:     ${BOLD}node${RESET}`);
    log(`    Args:        ${BOLD}path/to/cortex-mcp/dist/index.js${RESET}`);
    log("");
    log(`  ${DIM}See: https://github.com/BasharAmso/cortex-mcp${RESET}`);
    log(`  ${DIM}orchestrator.md and coach.md are installed locally.${RESET}`);
    log(`  ${DIM}All other agents and skills load from MCP on demand.${RESET}`);
  }

  log("");
  log(
    `${DIM}Documentation: README.md${RESET}`
  );
  log(
    `${DIM}Full reference: .claude/REFERENCE.md${RESET}`
  );
  log("");
}

main();
