# Digital Ebook Library

Full-stack ebook library. Rails API backend + Flutter frontend. Bookshelf-style UI inspired by the old iOS ebook library.

## Tech Stack

- **Backend:** Ruby on Rails 7.1 (API-only), SQLite, ActiveStorage (local disk), RSpec
- **Frontend:** Flutter 3.x, Provider (state mgmt), Syncfusion PDF viewer, http

## Repo Layout

```
ebook_library/
  backend/    Rails API
  frontend/   Flutter app
```

## Backend Setup

```bash
cd backend
bundle install
bin/rails db:create db:migrate
# optional demo data (seeds 3 sample ebooks with a placeholder PDF):
bin/rails db:seed
bin/rails server   # runs on http://localhost:3000
```

Run tests:
```bash
bundle exec rspec
```

### Storage approach
Uses **ActiveStorage** with the **local disk** service (`config/storage.yml`, `local`).
Files land in `backend/storage/`. `file_size` and `file_type` are derived from the
uploaded blob at save time, not trusted from user input. Swapping to S3 later is a
one-line change to `storage.yml` plus adding the `aws-sdk-s3` gem — no controller/model changes needed.

## Frontend Setup

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api   # Android emulator
# or, iOS simulator / desktop:
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

Run tests:
```bash
flutter test
```

**Physical device note:** `10.0.2.2` / `localhost` won't reach your dev machine from a
real phone. Use your machine's LAN IP instead, e.g. `--dart-define=API_BASE_URL=http://192.168.1.20:3000/api`.

## API Overview

| Method | Endpoint                    | Description                          |
|--------|------------------------------|---------------------------------------|
| GET    | `/api/ebooks`                | List all ebooks, newest first         |
| GET    | `/api/ebooks/:id`            | Ebook details                         |
| GET    | `/api/ebooks/search?q=...`   | Search by title/author/filename       |
| POST   | `/api/ebooks`                | Upload (multipart: title, author, file_type, file) |
| GET    | `/api/ebooks/:id/download`   | Redirects to file blob for download   |
| DELETE | `/api/ebooks/:id`            | Delete an ebook                       |

**Upload validations:** title required; file required; file_type must be `pdf` or `epub`;
declared file_type must match the file's actual content-type; max size 100MB.

### Example response (`GET /api/ebooks`)
```json
[
  {
    "id": 1,
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "file_type": "pdf",
    "file_size": 204800,
    "filename": "clean_code.pdf",
    "upload_date": "2026-07-01T10:00:00Z",
    "cover_image_url": null,
    "download_url": "http://localhost:3000/api/ebooks/1/download"
  }
]
```

## Product Decisions / Edge Cases

- **Empty library** → dedicated empty-shelf illustration + "Upload your first ebook" CTA, distinct from the "no search results" empty state.
- **Upload failure** → server error surfaced verbatim in a SnackBar; form stays filled so the user doesn't retype.
- **File too large** → checked client-side before upload starts (fast feedback) *and* server-side (source of truth, 100MB cap).
- **No search results** → explicit "No ebooks match your search" message, not a blank screen.
- **Loading** → spinner while list/search is in flight; upload button shows an inline spinner and disables the form.
- **Delete** → confirmation dialog naming the book; optimistic removal from the list, rolled back automatically if the API call fails.
- **Search** → debounced 400ms so it doesn't fire on every keystroke.

## Known Limitations

- No auth/multi-user — single shared library, matches assignment scope.
- EPUB reading not implemented in-app (EPUBs can still be uploaded/downloaded); reader screen shows a clear "download to read" message for non-PDF files.
- No cover-image auto-generation from PDF first page — cover upload is supported by the model/API but not wired into the upload UI yet (falls back to a colored placeholder with title).
- Last-read-position and full-screen reading mode not implemented (bonus items).
- CORS is wide open (`origins "*"`) for local development — tighten before any real deployment.

## AI Tool Usage

See [AI_USAGE.md](./AI_USAGE.md).

## Manual Testing Checklist

See [MANUAL_TESTING.md](./MANUAL_TESTING.md).
