class EbookSerializer
  def initialize(ebook, request)
    @ebook = ebook
    @request = request
  end

  def as_json(*)
    {
      id: @ebook.id,
      title: @ebook.title,
      author: @ebook.author,
      file_type: @ebook.file_type,
      file_size: @ebook.file_size,
      filename: @ebook.filename,
      upload_date: @ebook.upload_date.iso8601,
      cover_image_url: cover_url,
      download_url: download_url
    }
  end

  private

  def cover_url
    return nil unless @ebook.cover_image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(@ebook.cover_image, host: host)
  end

  def download_url
    Rails.application.routes.url_helpers.api_ebook_download_url(@ebook, host: host)
  end

  def host
    @request ? "#{@request.protocol}#{@request.host_with_port}" : "http://localhost:3000"
  end
end
