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
