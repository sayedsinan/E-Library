# Manual Testing Checklist

Run both services before testing:
```bash
# Terminal 1 — backend
cd backend && bin/rails server -b 0.0.0.0

# Terminal 2 — frontend (replace IP with your machine's LAN IP for physical device)
cd frontend && flutter run --dart-define=API_BASE_URL=http://192.168.29.13:3000/api
```

---

## 1. Library / Empty State

- [ ] First launch (no ebooks seeded) → empty shelf illustration is shown, not a blank screen
- [ ] "Upload your first ebook" button is visible and tappable on the empty state
- [ ] Library loads existing ebooks on app start, displayed in a bookshelf grid with wooden shelf planks
- [ ] Pull down on the shelf → refresh spinner appears, list reloads
- [ ] Book count shown in the header ("X books on shelf")

---

## 2. Upload

- [ ] Tap "Add Book" FAB → upload screen opens
- [ ] Tap file picker zone → file browser opens, only PDF/EPUB selectable
- [ ] Pick a valid PDF → filename shown in picker zone, title field auto-fills with filename (editable)
- [ ] Clear title and submit → form validation error "Title is required" shown, no request sent
- [ ] Submit with no file selected → inline error shown under picker zone, upload not attempted
- [ ] Pick a file > 100MB → client-side error displayed immediately, upload blocked
- [ ] Fill title + author + pick valid PDF → tap Upload → loading overlay appears
- [ ] On success → returns to shelf, new book appears first (top-left), success SnackBar shown
- [ ] Kill backend, attempt upload → error SnackBar shown with message; form stays filled
- [ ] Upload an EPUB file → accepted, appears on shelf with correct badge

---

## 3. Search

- [ ] Type a title fragment → results filter after ~400ms (debounce visible — no instant fire on every key)
- [ ] Type an author name fragment → correct books returned
- [ ] Type a filename fragment (e.g. "clean_code") → correct book returned
- [ ] Header updates to "Showing search results" while searching
- [ ] Type something with no matches → "No ebooks match your search" shown, not a blank screen
- [ ] Tap the ✕ clear button → search clears, full library reloads
- [ ] Search results have matching text highlighted in titles/authors

---

## 4. Sort & Filter

- [ ] Tap the sort/filter bar (below search) → sort options appear: Newest, Oldest, Title A–Z, Author A–Z
- [ ] Select "Title A–Z" → books reorder alphabetically
- [ ] Select "Author A–Z" → books reorder by author
- [ ] Select "Oldest" → books reorder oldest first
- [ ] Select "Newest" → books return to default newest-first order
- [ ] Filter by "PDF" → only PDF books shown
- [ ] Filter by "EPUB" → only EPUB books shown
- [ ] Filter by "All" → all books shown
- [ ] Sort + filter work together (e.g. PDFs only, sorted by title)

---

## 5. Reading

- [ ] Tap a PDF book cover → in-app PDF viewer opens
- [ ] PDF renders correctly, pages scrollable
- [ ] Scroll head and status indicators visible in PDF viewer
- [ ] Tap a non-PDF (EPUB) book → "reading coming soon" message shown with download suggestion
- [ ] Long-press any book → bottom sheet appears with Read / Download / Delete options
- [ ] Tap "Read" from action sheet → PDF viewer opens (same as tapping card)
- [ ] PDF load fails (corrupt file) → retry button shown, app doesn't crash

---

## 6. Recently Read

- [ ] Open several different books → "Recently Read" section appears at the top of the shelf
- [ ] Recently read shows the last 5 opened books in order
- [ ] Tapping a recently-read book opens it again in the reader
- [ ] Section does not appear if no books have been opened yet this session

---

## 7. Download

- [ ] Long-press book → tap "Download" → file opens / download triggered in external app
- [ ] Success: no error SnackBar, OS handles the file
- [ ] Backend down during download → error SnackBar shown, app doesn't crash

---

## 8. Delete

- [ ] Long-press book → tap "Delete" → confirmation dialog appears, names the correct book
- [ ] Tap "Cancel" → dialog closes, book remains in library
- [ ] Tap "Delete" (red button) → dialog closes, book disappears immediately from shelf
- [ ] Success SnackBar appears: `"BookTitle" deleted.`
- [ ] Kill backend, confirm delete → book reappears (rollback), error SnackBar shown
- [ ] Delete the last book → empty shelf state reappears

---

## 9. Error States

- [ ] Kill backend → tap Retry → app tries to reload
- [ ] Restart backend → tap Retry → library loads successfully
- [ ] Very slow connection → loading spinner shown throughout
- [ ] Invalid backend URL → timeout message shown (not a generic crash)

---

## 10. Backend API (via curl or Postman — optional cross-check)

```bash
# List all
curl http://localhost:3000/api/ebooks

# Upload
curl -X POST http://localhost:3000/api/ebooks \
  -F "ebook[title]=Test Book" \
  -F "ebook[file_type]=pdf" \
  -F "ebook[file]=@/path/to/file.pdf"

# Search
curl "http://localhost:3000/api/ebooks/search?q=test"

# Download (should redirect)
curl -L http://localhost:3000/api/ebooks/1/download -o downloaded.pdf

# Delete
curl -X DELETE http://localhost:3000/api/ebooks/1
```

- [ ] `GET /api/ebooks` → 200, JSON array
- [ ] `GET /api/ebooks` (empty DB) → 200, empty array `[]`
- [ ] `POST /api/ebooks` without file → 422 with `{"errors": [...]}`
- [ ] `POST /api/ebooks` without title → 422
- [ ] `POST /api/ebooks` with mismatched file_type (epub declared, PDF uploaded) → 422
- [ ] `GET /api/ebooks/999999` → 404
- [ ] `DELETE /api/ebooks/:id` → 204, book gone from subsequent GET
- [ ] `GET /api/ebooks/:id/download` → 302 redirect to blob URL
- [ ] `GET /api/ebooks/:id/download` for nonexistent ID → 404

---

## 11. Automated Tests

```bash
# Backend
cd backend && bundle exec rspec --format documentation

# Frontend
cd frontend && flutter test
```

- [ ] All RSpec tests pass (model specs + request specs)
- [ ] All Flutter tests pass (widget, provider, state views)
