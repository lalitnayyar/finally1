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

This project includes an automated GitHub workflow system for professional development with proper branching and Pull Request management.

### Quick Commands

```bash
# Create a new feature branch and PR with AI suggestions (recommended)
pr-workflow.bat auto

# Create a new feature branch and PR with interactive prompts  
pr-workflow.bat create

# Check git status and remotes  
pr-workflow.bat status

# Merge an approved PR back to main
pr-workflow.bat merge

# Get detailed help
pr-workflow.bat help
```

### AI-Powered Workflow

The workflow now includes AI-powered branch name and commit message generation:

- **`pr-workflow.bat auto`** - Fully automated: AI analyzes your changes and suggests everything
- **`pr-workflow.bat create`** - Interactive: AI provides suggestions you can accept or modify  
- **Intelligent suggestions** based on file types, change patterns, and Git best practices
- **Fallback support** - works even without AI/API access

### Workflow Process

1. **Make your code changes** locally and test them
2. **Create a PR with AI**: Run `pr-workflow.bat auto`
   - AI automatically analyzes changes and suggests branch names and commit messages
   - Or use `pr-workflow.bat create` for interactive mode with AI suggestions
3. **Review on GitHub**: Visit the provided link to review changes
4. **Merge PR**: Run `pr-workflow.bat merge [branch-name]` 
   - Merges to main branch and cleans up branches

### Branch Naming Conventions
- `feature/description` - New features
- `bugfix/description` - Bug fixes  
- `hotfix/description` - Urgent fixes
- `docs/description` - Documentation updates

### Repository
- **GitHub**: https://github.com/lalitnayyar/finally1.git
- **Workflow Documentation**: [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md)
- **Setup Guide**: [SETUP_COMPLETE.md](SETUP_COMPLETE.md) 
- **Quick Reference**: [QUICKSTART.md](QUICKSTART.md)

### AI Features Setup (Optional)
For AI-powered branch names and commit messages:
```bash
# Set your OpenRouter API key (same key used for the trading app)
set OPENROUTER_API_KEY=your-key-here

# Or add to your .env file
echo OPENROUTER_API_KEY=your-key-here >> .env
```
**Note**: AI features gracefully fall back to manual input if the API key is not set.

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
