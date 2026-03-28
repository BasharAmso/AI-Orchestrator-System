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

function copyDirRecursive(src, dest, stats) {
  if (!fs.existsSync(src)) return;

  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      if (!fs.existsSync(destPath)) {
        fs.mkdirSync(destPath, { recursive: true });
      }
      copyDirRecursive(srcPath, destPath, stats);
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

function main() {
  const args = process.argv.slice(2);

  if (args.includes("--help") || args.includes("-h")) {
    log(`
${BOLD}create-ai-orchestrator${RESET} v${VERSION}

Set up The AI Orchestrator System in any project.
Adds 12 agents, 36 skills, 20 commands, and 11 safety hooks
for structured AI-assisted development with Claude Code.

${BOLD}Usage:${RESET}
  npx create-ai-orchestrator          Install in current directory
  npx create-ai-orchestrator my-app   Create new directory and install

${BOLD}Options:${RESET}
  --help, -h     Show this help message
  --version, -v  Show version number
  --force        Overwrite existing files (default: skip)

${BOLD}What it does:${RESET}
  1. Copies the .claude/ framework (agents, skills, commands, hooks, rules)
  2. Creates clean project state files (STATE.md, EVENTS.md, etc.)
  3. Adds FRAMEWORK_VERSION, .claudeignore, and .gitignore
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
  const dirArg = args.find((a) => !a.startsWith("-"));
  const targetDir = dirArg ? path.resolve(dirArg) : process.cwd();

  log("");
  log(
    `${BOLD}The AI Orchestrator System${RESET} v${VERSION}`
  );
  log(
    `${DIM}12 agents | 36 skills | 20 commands | 11 safety hooks${RESET}`
  );
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
  log("Installing framework...");
  log("");

  const stats = { copied: 0, skipped: 0 };

  if (force && fs.existsSync(claudeDir)) {
    // In force mode, still don't delete — just overwrite individual files
    copyDirRecursive(
      TEMPLATE_DIR,
      targetDir,
      Object.assign(stats, { skipped: -stats.skipped })
    );
    // Reset: in force mode, we overwrite
    stats.skipped = 0;
    stats.copied = 0;
    copyDirForce(TEMPLATE_DIR, targetDir, stats);
  } else {
    copyDirRecursive(TEMPLATE_DIR, targetDir, stats);
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
  log("");
  log(
    `${DIM}Documentation: README.md${RESET}`
  );
  log(
    `${DIM}Full reference: .claude/REFERENCE.md${RESET}`
  );
  log("");
}

function copyDirForce(src, dest, stats) {
  if (!fs.existsSync(src)) return;

  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      if (!fs.existsSync(destPath)) {
        fs.mkdirSync(destPath, { recursive: true });
      }
      copyDirForce(srcPath, destPath, stats);
    } else {
      fs.mkdirSync(path.dirname(destPath), { recursive: true });
      fs.copyFileSync(srcPath, destPath);
      stats.copied++;
    }
  }
}

main();
