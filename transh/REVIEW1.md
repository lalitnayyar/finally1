# Review of PLAN.md

## High-Priority Feedback

### 1. Market data contract has drifted from the implemented subsystem

`planning/MARKET_DATA_SUMMARY.md` says the market data backend is complete, but `PLAN.md` still specifies API details that do not match the current code in `backend/app/market/`.

Observed mismatches:

- `PLAN.md` says each SSE event contains `ticker`, `price`, `previous_price`, `session_open`, `session_change_pct`, `timestamp`, and `change_direction`.
- The implemented stream sends one JSON object keyed by ticker, e.g. `{ "AAPL": { ... }, "MSFT": { ... } }`.
- The implemented `PriceUpdate.to_dict()` emits `change`, `change_percent`, and `direction`, not `session_open`, `session_change_pct`, or `change_direction`.
- The implemented timestamp is a Unix float, while the API examples in the plan use ISO timestamps.
- `PLAN.md` says the backend maintains a rolling history buffer of 500 points per ticker, but the current `PriceCache` stores only the latest point per ticker.

This is the most important issue because frontend, portfolio valuation, and API agents will build against the plan. Either update the plan to match the completed market-data code, or explicitly assign a follow-up task to add session-open tracking, ISO serialization, and the history buffer.

Recommended direction: make `PLAN.md` the source of truth before more agents start work. If the current backend is accepted, revise §6 and §8 to document the implemented SSE envelope and field names. If the richer contract is desired, add a market-data follow-up before frontend work begins.

### 2. `GET /api/market/history/{ticker}` is specified but not backed by current architecture

The plan depends on a 500-point in-memory rolling buffer so the main chart can show data immediately. The completed market-data subsystem summary does not mention this buffer, and the current cache only stores latest prices.

This endpoint should be resolved early because it affects:

- Main chart first-render behavior
- Frontend data model for selected ticker charts
- Memory ownership between `PriceCache`, a separate history store, and portfolio valuation
- Test expectations for market history

Recommendation: add a small `PriceHistoryBuffer` or extend the market-data package with a clearly named history component. Avoid putting this responsibility silently into frontend-only SSE accumulation, because `PLAN.md` already promises server-backed history.

### 3. Environment-variable requirements are internally inconsistent

§5 labels `OPENROUTER_API_KEY` as required, but the behavior section says the server starts normally without it and only `/api/chat` returns HTTP 503. `README.md` also marks it as required.

Recommendation: classify it as "required for AI chat, optional for core app startup." This matters for Docker quick start, CI, E2E tests, and local development without paid credentials.

### 4. LLM execution needs a stricter safety and audit contract, even with fake money

The plan deliberately allows automatic LLM trade execution without confirmation. That is reasonable for a simulated demo, but the backend contract should still define guardrails so agents implement consistent behavior.

Missing details:

- Maximum order size or maximum percent of available cash per LLM action
- Whether the LLM can liquidate all positions
- Whether tickers must already be in the watchlist before trading
- How multiple requested trades are ordered when cash constraints make later trades fail
- Whether assistant messages are stored before or after action execution
- Whether failed actions are persisted in full

Recommendation: add deterministic execution rules to §9, especially for multi-action responses. This will make backend tests much easier and prevent frontend/chat behavior from depending on incidental implementation order.

## Medium-Priority Feedback

### 5. Separate agent instructions from product specification

§9 says to use a specific coding-agent skill for Cerebras/OpenRouter integration. That is useful implementation guidance, but it does not belong in the production product spec.

Recommendation: move agent/tooling instructions to `CLAUDE.md` or a dedicated planning note. Keep `PLAN.md` focused on runtime behavior: LiteLLM, OpenRouter model/provider, structured output schema, retry/error behavior, and mock mode.

### 6. The API schema should define numeric precision and money semantics

The app trades fractional shares with `REAL` columns and returns rounded-looking values in examples, but the plan does not define rounding rules.

Recommendation: specify:

- Store quantities with a fixed maximum precision, such as 4 decimal places.
- Store cash, prices, costs, and P&L rounded to cents at API boundaries.
- Use exact decimal arithmetic for trade validation if practical, or document where float math is acceptable for this simulator.

This is especially important for tests around insufficient cash, full liquidation, and position deletion at zero quantity.

### 7. Portfolio snapshots may not be sufficient for a useful P&L chart

The plan records snapshots at startup, every 30 seconds, and after trades. That works, but if no trade occurs and prices move every 500ms, the displayed total value in the header will update while the P&L chart updates only every 30 seconds.

Recommendation: make the intended UX explicit. If a sparse P&L chart is acceptable, keep the 30-second snapshots. If the chart should feel live, generate chart points on the frontend from live valuation or record backend snapshots more frequently.

### 8. Watchlist removal needs a position/market-data rule

The plan allows removing tickers from the watchlist, and market data tracks the union of watched tickers. It does not say what happens if a user owns a position in a ticker and removes it from the watchlist.

This affects portfolio valuation. If the backend stops tracking the ticker, current price and unrealized P&L may become stale or unavailable.

Recommendation: define the tracked ticker universe as `watchlist ∪ open positions`, not watchlist alone. Removing a ticker from the watchlist should not stop market-data updates while the user still holds that ticker.

### 9. Static export plus FastAPI serving needs explicit routing behavior

The architecture says Next.js uses static export and FastAPI serves `/*`. The plan should state how client-side routes are handled, even if the initial app is a single page.

Recommendation: document a fallback that serves `index.html` for non-API paths, while ensuring `/api/*` and `/api/stream/*` are never swallowed by static routing.

## Existing Feedback Worth Keeping

The appended feedback in §13 is generally sound:

- The charting-library note is correct: Recharts is SVG-based, while Lightweight Charts is a better fit for financial time-series rendering.
- The state-management gap is real. A live price stream will feed multiple UI regions, so a small shared store such as Zustand or React Context should be specified.
- The warning about agent-specific skill instructions inside the spec is valid.

I would be more cautious about some simplification suggestions:

- Keeping `user_id = "default"` is noisy, but it is a reasonable low-cost hedge if future multi-user support is likely.
- Keeping `users_profile` as a table is preferable to treating cash as config, because cash is mutable user state.
- Storing action details in `chat_messages.actions` is useful for replaying chat history without reconstructing from timestamps. It is duplicate data, but acceptable if `trades` remains canonical and `actions` is treated as an immutable UI/audit snapshot.

## Suggested Next Edits to PLAN.md

1. Reconcile §6 and §8 with the completed market-data implementation, or create explicit follow-up tasks for the missing history/session fields.
2. Change `OPENROUTER_API_KEY` wording to "optional unless using chat."
3. Move agent-skill instructions out of §9.
4. Add a short "Portfolio valuation and ticker tracking" rule: market data tracks watchlist plus open positions.
5. Add deterministic rules for LLM multi-action execution and failed-action persistence.
6. Specify frontend shared state expectations and select Lightweight Charts as the primary charting library.

