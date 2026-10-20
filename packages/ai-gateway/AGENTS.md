# AGENTS.md: packages/ai-gateway

Owner: `ai-gateway`. Root rules apply.

- The ONLY place that talks to OpenRouter. dependency-cruiser forbids AI SDK imports anywhere else.
- `redact()` before every request; no personal data leaves the server. Cache shareable outputs by `cacheKey`.
- Model routes come from the database (`ai` module), with fallbacks; writer and verifier tasks use different model families.
- Enforce per-user limits and the monthly budget; degrade with `AiUnavailableError` → API returns `AI_BUSY`.
