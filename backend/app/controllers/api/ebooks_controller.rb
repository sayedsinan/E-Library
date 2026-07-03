module Api
  class EbooksController < ApplicationController
    before_action :set_ebook, only: [:show, :destroy, :download]

    # GET /api/ebooks
    def index
      ebooks = Ebook.order(created_at: :desc)
      render json: ebooks.map { |e| EbookSerializer.new(e, request).as_json }, status: :ok
    end

    # GET /api/ebooks/:id
    def show
      render json: EbookSerializer.new(@ebook, request).as_json, status: :ok
    end

    # GET /api/ebooks/search?q=keyword
    def search
      query = params[:q]
      ebooks = Ebook.search_by(query).order(created_at: :desc)
      render json: ebooks.map { |e| EbookSerializer.new(e, request).as_json }, status: :ok
    end

    # POST /api/ebooks  (multipart: file, cover_image, title, author)
    def create
      ebook = Ebook.new(ebook_params)

      if ebook.save
        render json: EbookSerializer.new(ebook, request).as_json, status: :created
      else
        render json: { errors: ebook.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/ebooks/:id
    def destroy
      @ebook.destroy
      head :no_content
    end

    # GET /api/ebooks/:id/download
    def download
      unless @ebook.file.attached?
        return render json: { error: "File not found" }, status: :not_found
      end

      redirect_to rails_blob_url(@ebook.file, disposition: "attachment"), allow_other_host: true
    end

    private

    def set_ebook
      @ebook = Ebook.find(params[:id])
    end

    def ebook_params
      params.require(:ebook).permit(:title, :author, :file_type, :file, :cover_image)
    end
  end
end
