# AI Tool Usage

> Note: fill this in with your own words before submitting — evaluators want to see
> *your* reflection on working with AI, not a boilerplate doc. The notes below reflect
> how this codebase was actually produced and are a starting point, not a final answer.

## Tools used

- **Claude** (Anthropic) — used for architecture, code generation across both Rails
  and Flutter, and test writing.

## How it was used

- **Architecture first, code second.** Before any code, decided on: API-only Rails app,
  ActiveStorage for files, a plain-Ruby serializer (no extra gem needed for this scope),
  Provider for Flutter state. This kept the AI's output scoped instead of over-engineering.
- **Model validations.** Asked for validations on title/file/file_type, then added one
  the first draft missed: verifying the uploaded file's *actual* content-type matches the
  declared `file_type`, so a renamed `.exe` can't slip through as a "pdf". That check
  (`file_content_type_matches` in `Ebook`) was a manual addition after reviewing the
  AI's first pass, which only checked the extension.
- **Search.** Initial AI draft used `ILIKE`, which is Postgres-only — this project uses
  SQLite, so it was corrected to `LIKE` (SQLite's default comparison is already
  case-insensitive for ASCII) and rewritten as a composable `scope` for testability.
- **Flutter state management.** Asked AI to draft `EbookProvider`. Rejected an initial
  version that called the API client through an unnecessary indirection layer — simplified
  to call `ApiService` directly, since the extra abstraction added complexity without
  adding testability (the class already takes an injected `ApiService` in its constructor).
- **Delete UX.** Requested optimistic UI (remove immediately, roll back on failure)
  instead of waiting for the server round-trip before updating the list — better perceived
  performance, matches the "update UI after deletion, handle failure gracefully" requirement.
- **Tests.** AI drafted the RSpec request/model specs and Flutter widget/provider tests.
  Reviewed each for: does it test behavior (not implementation details), does it cover the
  failure path, not just the happy path. Added the "content-type mismatch" and "rollback on
  delete failure" test cases specifically because those are the two edge cases most likely
  to be missed in a first pass.
- **Debugging.** Used AI to reason through the Rails route ordering issue where
  `GET /api/ebooks/search` could collide with `GET /api/ebooks/:id` — resolved by keeping
  `search` as a `collection` route inside the `resources :ebooks` block, which Rails
  orders ahead of the member `:id` route.

## What was manually reviewed / changed

- Content-type validation logic (see above).
- SQLite-compatible search query.
- Removed unnecessary indirection in `EbookProvider`.
- Verified CORS config only opens `/api/*`, not the whole app.
- Checked that `file_size`/`file_type` are always derived server-side from the actual
  upload, never trusted from client-supplied params, to avoid spoofed metadata.

## What was rejected

- An early suggestion to store `file_size` and `file_type` as user-submitted params
  directly — rejected because the client can lie about both; both are now derived from
  the ActiveStorage blob on save instead.
- A version of the bookshelf grid that hardcoded book count per shelf row based on
  screen-width breakpoints defined manually — simplified to a fixed 3-per-row grid for
  this scope, with a note that responsive breakpoints are a good bonus follow-up.
