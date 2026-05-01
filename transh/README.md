# FinAlly — AI Trading Workstation

An AI-powered trading workstation that streams live market data, simulates portfolio trading, and integrates an LLM chat assistant that can analyze positions and execute trades via natural language.

Built entirely by coding agents as a capstone for an agentic AI coding course.

## Features

- **Live price streaming** via SSE with green/red flash animations and sparklines
- **Simulated portfolio** — $10k virtual cash, market orders, instant fills
- **Portfolio visualizations** — heatmap (treemap), P&L chart, positions table
- **AI chat assistant** — analyzes holdings, suggests and auto-executes trades
- **Watchlist management** — add/remove tickers manually or via AI
- **Dark terminal aesthetic** — Bloomberg-inspired, data-dense layout

## Quick Start

```bash
cp .env.example .env
# Add OPENROUTER_API_KEY to .env

# macOS/Linux
./scripts/start_mac.sh

# Windows
./scripts/start_windows.ps1

# Or build and run directly
docker build -t finally .
docker run -v finally-data:/app/db -p 8000:8000 --env-file .env finally
```

Open [http://localhost:8000](http://localhost:8000).

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `OPENROUTER_API_KEY` | Yes | OpenRouter API key for AI chat |
| `MASSIVE_API_KEY` | No | Polygon.io key for real market data; omit to use the built-in simulator |
| `LLM_MOCK` | No | Set `true` for deterministic mock responses (testing/CI) |

## Architecture

Single Docker container on port 8000:

- **Frontend**: Next.js (static export), TypeScript, Tailwind CSS
- **Backend**: FastAPI (Python/uv), SSE streaming
- **Database**: SQLite, lazy-initialized on first start
- **AI**: LiteLLM → OpenRouter (Cerebras) with structured outputs
- **Market data**: GBM simulator (default) or Massive/Polygon.io API

## Project Structure

```
finally/
├── frontend/    # Next.js static export
├── backend/     # FastAPI uv project
├── planning/    # Project documentation and agent contracts
├── test/        # Playwright E2E tests
├── scripts/     # Start/stop helpers (mac + windows)
└── db/          # SQLite volume mount (runtime)
```

## License

See [LICENSE](LICENSE).
