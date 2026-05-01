# FinAlly — AI Trading Workstation

A visually stunning AI-powered trading workstation that streams live market data, lets you trade a simulated portfolio, and includes an LLM chat assistant that can analyze positions and execute trades on your behalf.

Built as a capstone project for an agentic AI coding course — the entire codebase is produced by orchestrated AI agents.

## Features

- **Live price streaming** — prices flash green/red on change via SSE
- **Simulated portfolio** — $10,000 starting cash, market orders, instant fills
- **Portfolio heatmap** — treemap sized by weight, colored by P&L
- **P&L chart** — portfolio value over time
- **AI chat assistant** — natural language trade execution and watchlist management
- **Bloomberg-inspired UI** — dark, data-dense terminal aesthetic

## Quick Start

```bash
# Copy and configure environment variables
cp .env.example .env
# Edit .env — add your OPENROUTER_API_KEY (required for AI chat)

# Start (macOS/Linux)
./scripts/start_mac.sh

# Start (Windows PowerShell)
./scripts/start_windows.ps1
```

Open [http://localhost:8000](http://localhost:8000).

## GitHub Workflow

This project includes an **AI-powered automated GitHub workflow system** for professional development with proper branching and Pull Request management. The workflow supports everything from interactive prompts to **full automation with auto-merge**.

### 🚀 Quick Runbook - For Every Change

**For maximum efficiency, use this command for every code change:**
```bash
# One command does it all: AI analysis, branch creation, commit, push, PR creation, and auto-merge
pr-workflow.bat automerge
```

**What this does:**
1. ✅ Analyzes your changes with AI
2. ✅ Suggests intelligent branch names and commit messages
3. ✅ Creates branch, commits, and pushes to GitHub
4. ✅ **Automatically creates and merges the PR** (with GitHub CLI)
5. ✅ Switches back to main and pulls latest changes
6. ✅ Cleans up merged branches

### All Available Commands

| Command | What It Does | When To Use |
|---------|-------------|-------------|
| `pr-workflow.bat automerge` | **🚀 FULL AUTOMATION** - AI + auto-merge | **Default choice** - fastest workflow |
| `pr-workflow.bat auto` | AI creates branch/commit, manual PR merge | When you want to review PR before merging |
| `pr-workflow.bat create` | Interactive mode with AI suggestions | When you want full control over names/messages |
| `pr-workflow.bat merge [branch]` | Merge existing PR to main | When merging PRs created outside this workflow |
| `pr-workflow.bat status` | Show git status and repository info | Check current state before making changes |
| `pr-workflow.bat help` | Detailed help and examples | Learn about all features and options |

### 🤖 AI-Powered Features

**Intelligent Analysis:**
- Automatically analyzes git diff to understand your changes
- Suggests appropriate branch names based on file types and change patterns
- Generates descriptive commit messages following best practices
- Falls back gracefully to manual input if AI is unavailable

**Smart Branch Naming:**
- `feature/description` - New features and enhancements
- `bugfix/description` - Bug fixes and corrections
- `hotfix/description` - Urgent production fixes
- `docs/description` - Documentation updates

### 🔧 Prerequisites for Full Automation

**Required for `automerge` command:**
```bash
# Install GitHub CLI (enables auto-merge functionality)
winget install GitHub.cli
# or visit: https://cli.github.com/

# Authenticate with GitHub
gh auth login
```

**Optional for AI features:**
```bash
# Set OpenRouter API key for AI-powered suggestions
set OPENROUTER_API_KEY=your-key-here
# (Same key used for the trading app's chat feature)
```

### 📋 Complete Workflow Process

1. **Make Code Changes** - Edit files, add features, fix bugs
2. **Run Automated Workflow**:
   ```bash
   pr-workflow.bat automerge  # Recommended for speed
   ```
3. **Done!** - Changes are automatically:
   - Committed with AI-generated message
   - Pushed to GitHub in new branch  
   - Created as Pull Request
   - **Automatically merged to main**
   - Branch cleaned up
   - Local main branch updated

### 🛠️ Advanced Options

**For Manual Control:**
```bash
# Interactive mode with AI suggestions you can modify
pr-workflow.bat create

# AI analysis but manual PR review/merge
pr-workflow.bat auto

# Check status before making changes
pr-workflow.bat status
```

**For Existing PRs:**
```bash
# Merge a PR created through GitHub web interface
pr-workflow.bat merge feature/my-branch
```

### 📚 Documentation & Links

- **GitHub Repository**: https://github.com/lalitnayyar/finally1.git
- **Detailed Workflow Guide**: [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)
- **Setup Instructions**: [SETUP_COMPLETE.md](SETUP_COMPLETE.md) 
- **Quick Reference**: [QUICKSTART.md](QUICKSTART.md)

### 🔍 Troubleshooting

**GitHub CLI Not Found:**
- `automerge` falls back to manual PR creation
- Install GitHub CLI for full automation: `winget install GitHub.cli`

**AI Suggestions Not Working:**
- Workflow falls back to manual input prompts
- Set `OPENROUTER_API_KEY` environment variable for AI features

**Uncommitted Changes Error:**
- Script now handles this gracefully
- Choose to continue on current branch or create new branch

**Branch Already Exists:**
- Script detects and stays on existing branch
- Continues workflow without creating duplicate branch

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `OPENROUTER_API_KEY` | Yes (for chat) | OpenRouter API key for LLM integration |
| `MASSIVE_API_KEY` | No | Polygon.io key for real market data; omit to use the built-in simulator |
| `LLM_MOCK` | No | Set `true` for deterministic mock LLM responses (testing) |

## Architecture

Single Docker container on port 8000:

- **Frontend** — Next.js (TypeScript), built as a static export, served by FastAPI
- **Backend** — FastAPI (Python/uv), REST + SSE endpoints
- **Database** — SQLite, volume-mounted at `db/finally.db`
- **Market data** — GBM simulator (default) or Massive/Polygon.io REST API
- **AI** — LiteLLM → OpenRouter (Cerebras inference), structured outputs

## Development

```bash
# Backend
cd backend
uv sync --extra dev
uv run pytest

# Frontend
cd frontend
npm install
npm run dev
```

## Project Structure

```
finally/
├── frontend/          # Next.js TypeScript app
├── backend/           # FastAPI uv project
├── planning/          # Architecture docs and agent specs
├── scripts/           # Start/stop Docker scripts
├── test/              # Playwright E2E tests
├── db/                # SQLite volume mount target
└── Dockerfile
```
