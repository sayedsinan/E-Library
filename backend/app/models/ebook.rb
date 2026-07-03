class Ebook < ApplicationRecord
  # file: the actual PDF/EPUB
  has_one_attached :file
  # cover_image: optional cover art
  has_one_attached :cover_image

  ALLOWED_FILE_TYPES = %w[pdf epub].freeze
  ALLOWED_CONTENT_TYPES = {
    "pdf" => "application/pdf",
    "epub" => "application/epub+zip"
  }.freeze
  MAX_FILE_SIZE = 100.megabytes

  before_validation :set_upload_date, on: :create
  before_validation :derive_file_metadata, on: :create

  validates :title, presence: true
  validates :file_type, inclusion: { in: ALLOWED_FILE_TYPES }
  validates :file, presence: { message: "must be attached" }, on: :create
  validate :file_content_type_matches, on: :create
  validate :file_size_within_limit, on: :create

  scope :search_by, ->(query) {
    return all if query.blank?

    sanitized = "%#{sanitize_sql_like(query)}%"
    where("title LIKE :q OR author LIKE :q", q: sanitized)
      .or(where("EXISTS (SELECT 1 FROM active_storage_attachments asa
                          JOIN active_storage_blobs asb ON asb.id = asa.blob_id
                          WHERE asa.record_id = ebooks.id
                            AND asa.record_type = 'Ebook'
                            AND asa.name = 'file'
                            AND asb.filename LIKE ?)", sanitized))
  }

  def filename
    file.attached? ? file.filename.to_s : nil
  end

  private

  def set_upload_date
    self.upload_date ||= Time.current
  end

  def derive_file_metadata
    return unless file.attached?

    self.file_size = file.blob.byte_size
    ext = File.extname(file.filename.to_s).delete(".").downcase
    self.file_type ||= ext
  end

  def file_content_type_matches
    return unless file.attached?

    expected = ALLOWED_CONTENT_TYPES[file_type]
    if expected.nil?
      errors.add(:file, "has an unsupported type (#{file_type})")
    elsif file.blob.content_type != expected
      errors.add(:file, "content type (#{file.blob.content_type}) does not match declared type (#{file_type})")
    end
  end

  def file_size_within_limit
    return unless file.attached?

    if file.blob.byte_size > MAX_FILE_SIZE
      errors.add(:file, "is too large (max #{MAX_FILE_SIZE / 1.megabyte}MB)")
    end
  end
end
