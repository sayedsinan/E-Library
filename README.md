# Digital Ebook Library

A full-stack digital ebook library application built as part of a Full Stack Developer evaluation for **Sagar Fab International Company**.

The backend is a Ruby on Rails 7 API. The frontend is a Flutter app with a classic wooden bookshelf UI inspired by the older iOS ebook library experience. Books can be uploaded, searched, read in-app, downloaded, and deleted.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Project Structure](#project-structure)
3. [Backend Setup](#backend-setup)
4. [Frontend Setup](#frontend-setup)
5. [Running Tests](#running-tests)
6. [API Reference](#api-reference)
7. [Features](#features)
8. [Product Decisions](#product-decisions)
9. [Known Limitations](#known-limitations)
10. [AI Tool Usage](#ai-tool-usage)
11. [Manual Testing](#manual-testing)

---

## Tech Stack

| Layer       | Technology                                                              |
|-------------|-------------------------------------------------------------------------|
| Backend     | Ruby on Rails 7.1 (API-only), SQLite 3, ActiveStorage (local disk), Puma |
| Backend Tests | RSpec 6.1, FactoryBot, Faker, Shoulda-Matchers                       |
| Frontend    | Flutter 3.44, Dart 3.12, Provider (state management)                    |
| PDF Viewer  | Syncfusion Flutter PDF Viewer                                           |
| HTTP Client | `http` package (Dart)                                                   |
| File Picker | `file_picker` package                                                   |

---

## Project Structure

```
E-Library/
├── backend/                          # Rails API
│   ├── app/
│   │   ├── controllers/
│   │   │   └── api/ebooks_controller.rb
│   │   ├── models/
│   │   │   └── ebook.rb
│   │   └── serializers/
│   │       └── ebook_serializer.rb
│   ├── config/
│   │   ├── routes.rb
│   │   ├── initializers/cors.rb
│   │   └── storage.yml
│   ├── db/
│   │   ├── migrate/
│   │   ├── schema.rb
│   │   ├── seeds.rb
│   │   └── sample_files/
│   │       └── sample.pdf            # used by db:seed
│   ├── spec/
│   │   ├── models/ebook_spec.rb
│   │   ├── requests/api/ebooks_spec.rb
│   │   └── factories/ebooks.rb
│   ├── Gemfile
│   └── Gemfile.lock
│
├── frontend/                         # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── models/ebook.dart
│   │   ├── services/api_service.dart
│   │   ├── providers/ebook_provider.dart
│   │   ├── controllers/
│   │   │   ├── library_controller.dart
│   │   │   └── upload_controller.dart
│   │   ├── screens/
│   │   │   ├── library_screen.dart
│   │   │   ├── upload_screen.dart
│   │   │   └── reader_screen.dart
│   │   ├── widgets/
│   │   │   ├── ebook_shelf.dart
│   │   │   ├── ebook_card.dart
│   │   │   ├── state_views.dart
│   │   │   ├── delete_confirm_dialog.dart
│   │   │   ├── common/
│   │   │   │   ├── app_search_field.dart
│   │   │   │   ├── app_snackbar.dart
│   │   │   │   └── highlighted_text.dart
│   │   │   ├── library/
│   │   │   │   ├── library_header.dart
│   │   │   │   ├── sort_filter_bar.dart
│   │   │   │   └── recently_read_strip.dart
│   │   │   ├── upload/
│   │   │   │   └── file_picker_zone.dart
│   │   │   └── ebook/
│   │   │       └── ebook_actions_sheet.dart
│   │   └── core/
│   │       ├── constants/app_constants.dart
│   │       ├── theme/
│   │       │   ├── app_theme.dart
│   │       │   └── app_colors.dart
│   │       └── utils/
│   │           ├── debouncer.dart
│   │           └── ebook_utils.dart
│   ├── test/
│   │   ├── widget_test.dart
│   │   ├── ebook_card_test.dart
│   │   ├── ebook_provider_test.dart
│   │   └── state_views_test.dart
│   └── pubspec.yaml
│
├── README.md
├── AI_USAGE.md
└── MANUAL_TESTING.md
```

---

## Backend Setup

### Prerequisites

- Ruby 4.0.5 — download from [rubyinstaller.org](https://rubyinstaller.org/downloads/) (Windows) or use `rbenv`/`rvm`
- Bundler — `gem install bundler`

### Install and Start

```bash
cd backend

# Install gems
bundle install

# Create and migrate the database
bin/rails db:create db:migrate

# (Optional) Seed 3 demo ebooks — sample.pdf already included in db/sample_files/
bin/rails db:seed

# Start the server on http://localhost:3000
bin/rails server

# To accept connections from a physical phone on your local network:
bin/rails server -b 0.0.0.0
```

### Storage

Uses **ActiveStorage** with the **local disk** service. Uploaded files land in `backend/storage/`. The `file_size` and `file_type` fields are always derived server-side from the uploaded blob — they are never trusted from client-supplied parameters. Swapping to S3 or another cloud provider later is a one-line change in `config/storage.yml`.

---

## Frontend Setup

### Prerequisites

- Flutter 3.44+ — [flutter.dev/get-started](https://docs.flutter.dev/get-started/install)
- A connected Android/iOS device, Android emulator, or desktop target

### Install and Run

```bash
cd frontend

# Install packages
flutter pub get

# Run on Android emulator (host machine is reachable at 10.0.2.2)
flutter run --dart-define=API_BASE_URL=yourip:3000/api

# Run on iOS simulator or desktop
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api

# Run on a physical phone (find your machine's IP with `ipconfig` on Windows or `ifconfig` on Mac/Linux)
flutter run --dart-define=API_BASE_URL=http://192.168.X.X:3000/api

# Run in Chrome (web)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

> **Note:** When running on a physical device, both the phone and your development machine must be on the same Wi-Fi network. Start Rails with `bin/rails server -b 0.0.0.0` so it listens on the network interface.

---

## Running Tests

### Backend (RSpec)

```bash
cd backend

# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run individual suites
bundle exec rspec spec/models/ebook_spec.rb
bundle exec rspec spec/requests/api/ebooks_spec.rb
```

**What is covered:**
- Model validations: title required, file required, file type must be `pdf`/`epub`, content-type must match declared type, file size within limit
- Model callbacks: `upload_date` auto-set, `file_size`/`file_type` derived from blob
- `Ebook.search_by` scope: title match, author match, empty query returns all, no-match returns empty
- Request specs for all 6 endpoints: happy path and error cases (404, 422, content-type mismatch)

### Frontend (Flutter)

```bash
cd frontend

# Run all tests
flutter test

# Run with verbose output
flutter test --reporter expanded
```

**What is covered:**
- `EbookCard` widget: title/author rendering, null author handling, tap callback, long-press action sheet
- `EbookProvider`: load success/error, search filtering, empty query fallback, optimistic delete with rollback, upload prepend
- State views: `EmptyShelfView`, `LoadingView`, `ErrorView` — rendering and retry callback
- App smoke test: library screen loads with correct header and FAB

---

## API Reference

Base path: `/api`

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/ebooks` | List all ebooks, ordered newest first |
| `GET` | `/api/ebooks/:id` | Get a single ebook by ID |
| `GET` | `/api/ebooks/search?q=keyword` | Search by title, author, or filename |
| `POST` | `/api/ebooks` | Upload a new ebook (multipart form) |
| `GET` | `/api/ebooks/:id/download` | Download ebook file (302 → blob URL) |
| `DELETE` | `/api/ebooks/:id` | Delete an ebook |

### Upload Request — `POST /api/ebooks`

```
Content-Type: multipart/form-data

ebook[title]       string   required
ebook[author]      string   optional
ebook[file_type]   string   "pdf" or "epub"
ebook[file]        file     required
ebook[cover_image] file     optional
```

**Validations enforced on the server:**
- `title` — must be present
- `file` — must be attached
- `file_type` — must be `pdf` or `epub`
- File content-type must match the declared `file_type` (prevents spoofed extensions)
- File size must not exceed 100 MB

### Response Shape

```json
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
```

### Error Responses

```json
// 422 Unprocessable Entity
{ "errors": ["Title can't be blank", "File must be attached"] }

// 404 Not Found
{ "error": "Couldn't find Ebook with 'id'=999" }
```

---

## Features

### Core Features

| Feature | Details |
|---------|---------|
| **Upload** | PDF and EPUB files up to 100MB. Title auto-filled from filename (editable). Author optional. |
| **Library view** | Classic bookshelf grid with wooden shelf planks. Each book shows cover image or colored placeholder, title, author, file type badge, and file size. |
| **Search** | Debounced (400ms) search by title, author, or filename via the backend. Highlights matching text in results. |
| **Sort** | Sort by: Newest, Oldest, Title A–Z, Author A–Z. Applied client-side on current results. |
| **Filter** | Filter by file type: All / PDF / EPUB. Works alongside search and sort. |
| **Reading** | In-app PDF viewer (Syncfusion). EPUBs show a "download to read" message. |
| **Download** | Opens the file via the OS external handler. |
| **Delete** | Confirmation dialog naming the specific book. Optimistic removal with automatic rollback if the API call fails. |
| **Recently Read** | A horizontal strip above the shelf shows the last 5 opened books for quick re-access. |

### State Handling

| State | Behavior |
|-------|----------|
| Empty library | Shelf illustration + "Upload your first ebook" button |
| Search no results | "No ebooks match your search" — not a blank screen |
| Loading | Spinner with "Loading your library…" text |
| Error | Error message + Retry button |
| Upload in progress | Full-screen loading overlay, form disabled |

---

## Product Decisions

These are deliberate UX and architecture decisions made during development:

- **Optimistic delete** — the book disappears from the shelf immediately and is restored automatically if the delete API call fails. This avoids making the user wait for a round-trip before seeing feedback.
- **Client-side file validation** — size and extension are checked before the upload request is sent, giving instant feedback without a server round-trip. The server also enforces the same rules as the source of truth.
- **Content-type mismatch validation** — the backend checks that the actual file content-type matches the declared `file_type`. A renamed `.exe` cannot be uploaded as a "pdf".
- **Server-side metadata only** — `file_size` and `file_type` are derived from the uploaded blob on the server, not trusted from client params. Clients cannot spoof metadata.
- **Debounced search** — 400ms debounce prevents a request on every keystroke while still feeling responsive.
- **Empty states are distinct** — an empty library and "no search results" show different messages and icons so the user always understands why the shelf is empty.
- **CORS scoped to `/api/*`** — only the API namespace is open to cross-origin requests, not the entire Rails app.
- **Route ordering** — `GET /api/ebooks/search` is defined as a `collection` route inside `resources :ebooks`, ensuring Rails routes it before the `GET /api/ebooks/:id` member route, preventing a collision.

---

## Known Limitations

- **No authentication** — single shared library. Multi-user auth is out of scope for this assignment.
- **EPUB in-app reading** — EPUBs can be uploaded, downloaded, and opened externally, but in-app rendering is not implemented. The Syncfusion PDF viewer is PDF-only.
- **Cover image upload UI** — the API and model support attaching a cover image, but the upload form does not expose this field. Books fall back to a colored placeholder generated from the title.
- **Last read page position** — the recently read list is tracked in memory for the session, but the specific page number within a PDF is not persisted across app restarts.
- **CORS is wide open** — `origins "*"` is fine for local development but must be restricted to specific origins before any production deployment.
- **SQLite only** — no connection pool or concurrent write handling. Sufficient for this assignment; swap to PostgreSQL for production.

---

## AI Tool Usage

See [AI_USAGE.md](./AI_USAGE.md) for a full breakdown of which tools were used, how AI was used as a development partner, what was manually reviewed and changed, and what AI-generated output was rejected.

---

## Manual Testing

See [MANUAL_TESTING.md](./MANUAL_TESTING.md) for the complete checklist covering all user flows: upload, search, sort/filter, reading, download, delete, recently read, error states, and backend API verification.
