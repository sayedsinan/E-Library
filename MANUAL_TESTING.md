# Manual Testing Checklist

Run backend (`bin/rails server`) and frontend (`flutter run`) together before testing.

## Library / Empty State
- [ ] Fresh install, no ebooks → empty-shelf message + "Upload" CTA shown
- [ ] Library loads existing ebooks on app start, shown on wooden shelf grid

## Upload
- [ ] Pick a valid PDF → title auto-fills from filename, editable
- [ ] Submit with title + PDF → success, returns to shelf, new book appears first
- [ ] Submit with no file selected → inline error, no request sent
- [ ] Submit with no title → form validation blocks submit
- [ ] Pick a file > 100MB → client-side error shown, upload blocked
- [ ] Pick a non-pdf/epub file → file picker filter prevents selection
- [ ] Kill backend, attempt upload → error SnackBar with server message, form retains input

## Search
- [ ] Type a matching title fragment → results filter after ~400ms pause
- [ ] Type a matching author fragment → correct results returned
- [ ] Type something with no matches → "No ebooks match your search" shown
- [ ] Clear search → full library reloads

## Reading
- [ ] Tap a PDF ebook → opens in-app PDF viewer, pages scroll/zoom
- [ ] Long-press a book → action sheet (Read / Download / Delete) appears
- [ ] Tap "Read" from action sheet → same as tapping the card

## Download
- [ ] Tap Download from action sheet → file download starts / opens externally
- [ ] Backend down → download error surfaced, doesn't crash app

## Delete
- [ ] Tap Delete → confirmation dialog names the correct book
- [ ] Cancel → book remains in library
- [ ] Confirm → book disappears immediately, SnackBar confirms
- [ ] Kill backend, confirm delete → book reappears (rollback), error SnackBar shown

## Backend (via curl or Postman, optional cross-check)
- [ ] `GET /api/ebooks` → 200, JSON array
- [ ] `POST /api/ebooks` without file → 422 with error message
- [ ] `GET /api/ebooks/:bad_id` → 404
- [ ] `DELETE /api/ebooks/:id` → 204, book gone from subsequent GET
- [ ] `GET /api/ebooks/:id/download` → 302 redirect to file
