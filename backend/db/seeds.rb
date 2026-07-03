# Seed a couple of demo ebooks so the shelf isn't empty on first run.
# Requires a tiny sample PDF at db/sample_files/sample.pdf (see README).

sample_path = Rails.root.join("db", "sample_files", "sample.pdf")

if File.exist?(sample_path)
  [
    { title: "The Pragmatic Programmer", author: "Andrew Hunt" },
    { title: "Clean Code", author: "Robert C. Martin" },
    { title: "Design Patterns", author: "Gang of Four" }
  ].each do |attrs|
    ebook = Ebook.new(attrs.merge(file_type: "pdf"))
    ebook.file.attach(io: File.open(sample_path), filename: "#{attrs[:title].parameterize}.pdf", content_type: "application/pdf")
    ebook.save!
  end
  puts "Seeded #{Ebook.count} ebooks."
else
  puts "No sample PDF found at #{sample_path} — skipping seed. See README to add one."
end
