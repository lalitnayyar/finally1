# Review 1 - PLAN.md

## Summary

The plan is strong as a product brief and gives agents a clear target experience. The main risks are not feature ambition, but contract ambiguity between agents: several choices are specified at a high level but leave enough behavioral gaps that independently implemented backend, frontend, and test work could drift apart.

## Findings

### 1. LLM auto-execution needs explicit safety and determinism rules

The plan says assistant-proposed trades execute automatically because the money is simulated. That is acceptable for the demo, but the execution contract is underspecified:

- Does the assistant execute trades only when the user explicitly asks, or can it proactively trade after giving advice?
- Should ambiguous requests like "make my portfolio better" execute trades or only recommend a plan?
- What limits prevent the assistant from spending all available cash, creating extreme concentration, or repeatedly trading in a loop?
- Should LLM-generated tickers be validated against market-data availability before being added or traded?

Recommendation: add a short "LLM trading policy" section. For example: execute only on explicit imperative/consent language, reject ambiguous intent, cap any single LLM trade to available cash/holdings, validate ticker format/source support, and return failed actions in the structured response.

### 2. REST responses and SSE events do not share one canonical market-data schema

The plan lists overlapping price fields across `/api/watchlist`, `/api/stream/prices`, portfolio responses, and history, but it does not define one canonical `PriceUpdate` API model. This increases the chance that backend routes and frontend stores normalize the same data differently.

Recommendation: define shared response models in the plan, especially for:

- `PriceQuote`: `ticker`, `price`, `previous_price`, `session_open`, `session_change_pct`, `timestamp`, `change_direction`
- `PricePoint`: `ticker`, `price`, `timestamp`
- `Position`: include whether `current_price` can be null before the first market tick

This should also state whether all money/quantity values are raw floats or rounded for display only.

### 3. Portfolio math needs more edge-case detail before implementation

The plan covers core trade behavior, but several accounting details are missing:

- Whether short selling is impossible or represented by negative quantities
- Whether fractional share quantity precision is limited
- How average cost changes on partial sells
- Whether selling all shares uses exact zero comparison or a tolerance
- What happens if a trade is requested before the current ticker price is available
- Whether portfolio total value uses latest cached prices, avg cost fallback, or rejects unavailable prices

Recommendation: add a "Portfolio invariants" subsection. The most straightforward contract is: no shorts, quantity must be positive, fractional shares allowed to a fixed precision, partial sells leave `avg_cost` unchanged, full liquidation deletes the row, and trades require a current price.

### 4. Static Next.js export may constrain frontend implementation more than stated

The plan requires `output: 'export'`, served by FastAPI. That rules out Next.js server features, API routes, server actions, dynamic server rendering, and image optimization. This is a good deployment simplification, but the restriction should be explicit for frontend agents.

Recommendation: add a frontend constraint note: all runtime data must be fetched client-side from FastAPI; no Next.js API routes/server actions; avoid features incompatible with static export.

### 5. Docker and local development contracts are incomplete

The plan is clear about the production-style single container, but less clear about local development. Agents may independently choose incompatible dev workflows.

Recommendation: specify expected dev commands and ports:

- Backend dev command and port
- Frontend dev command and port, if used during development
- Whether frontend dev server proxies `/api` to FastAPI
- Whether Docker is the only supported integration path
- Whether `.env.example` must be committed and `.env` must remain ignored

This will make E2E setup and start scripts less guesswork-driven.

### 6. Database initialization needs concurrency and migration rules

Lazy initialization is simple, but concurrent first requests or multiple workers can race unless the backend guarantees serialized init. The plan also says no separate migration step, but production code still needs a versioning story if schema changes during the project.

Recommendation: define that database initialization runs once during FastAPI lifespan startup, before routes accept traffic, and that schema changes during development use either idempotent SQL migrations or a simple `schema_version` table.

### 7. Watchlist and market-data lifecycle need one source of truth

The plan says the SSE stream pushes all tickers known to the system and that, in single-user mode, this is equivalent to the watchlist. It also says market data supports `add_ticker` and `remove_ticker`. The contract should state exactly when backend watchlist mutations update the market-data source.

Recommendation: specify:

- On startup, seed market data from DB watchlist.
- On watchlist add, persist first, then subscribe ticker to market data.
- On watchlist remove, unsubscribe only if no position still requires pricing.
- Positions should continue receiving prices even if removed from watchlist, or portfolio valuation will become stale.

### 8. Testing strategy should identify minimum release gates

The testing section is comprehensive, but it reads like a wishlist. It does not say which tests are required for the capstone to be considered shippable.

Recommendation: add a "minimum acceptance suite" with a small mandatory set:

- Backend unit tests for trade validation and portfolio valuation
- API tests for watchlist, portfolio, chat mock mode, and health
- One Docker-based Playwright smoke test for first launch, streaming prices, one buy, one sell, and mocked chat

Keep the broader list as stretch coverage.

## Smaller Notes

- The plan says `OPENROUTER_API_KEY` is required in the README-style quick start, but the spec says the server starts without it and only `/api/chat` returns 503. Align these descriptions.
- The phrase "Massive (Polygon.io)" should be defined once. If Massive is the client package and Polygon.io is the provider, say that explicitly.
- `portfolio_snapshots` recorded every 30 seconds can grow unbounded. Add a retention policy or cap for a demo app.
- The SSE endpoint should specify heartbeat behavior so proxies and browser clients do not treat quiet periods as dead connections.
- Consider adding `order_id` or `source` to `trades` so manual trades and assistant trades can be distinguished without relying on chat action JSON.
- Add API validation rules for ticker casing, allowed characters, maximum watchlist size, and duplicate handling.
- Clarify whether the app targets current market sessions only, or whether simulator mode intentionally runs 24/7.

## Recommended Plan Changes

1. Add explicit invariants for portfolio accounting and LLM trade execution.
2. Define canonical API models shared by REST and SSE.
3. Clarify static-export frontend constraints and local dev commands.
4. Tighten lifecycle rules for database initialization and watchlist-driven market subscriptions.
5. Convert the testing section into mandatory release gates plus optional stretch tests.
