require "rails_helper"

RSpec.describe "Api::Ebooks", type: :request do
  let(:sample_pdf) do
    fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf")
  end

  describe "GET /api/ebooks" do
    it "returns all ebooks, most recent first" do
      old = create(:ebook, title: "Old Book", created_at: 2.days.ago)
      new = create(:ebook, title: "New Book", created_at: 1.hour.ago)

      get "/api/ebooks"

      expect(response).to have_http_status(:ok)
      titles = JSON.parse(response.body).map { |e| e["title"] }
      expect(titles).to eq(["New Book", "Old Book"])
    end

    it "returns an empty array when the library has no ebooks" do
      get "/api/ebooks"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "GET /api/ebooks/:id" do
    it "returns the ebook details" do
      ebook = create(:ebook, title: "Specific Book")
      get "/api/ebooks/#{ebook.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["title"]).to eq("Specific Book")
    end

    it "returns 404 for a missing ebook" do
      get "/api/ebooks/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/ebooks/search" do
    it "returns matches for the query" do
      create(:ebook, title: "Rails Handbook")
      create(:ebook, title: "Flutter Handbook")

      get "/api/ebooks/search", params: { q: "Rails" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.length).to eq(1)
      expect(body.first["title"]).to eq("Rails Handbook")
    end

    it "returns an empty array when nothing matches" do
      create(:ebook, title: "Rails Handbook")
      get "/api/ebooks/search", params: { q: "nonexistent" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "POST /api/ebooks" do
    it "creates an ebook with a valid file" do
      expect {
        post "/api/ebooks", params: {
          ebook: { title: "New Upload", author: "Author X", file_type: "pdf", file: sample_pdf }
        }
      }.to change(Ebook, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["title"]).to eq("New Upload")
    end

    it "rejects upload without a title" do
      post "/api/ebooks", params: {
        ebook: { file_type: "pdf", file: sample_pdf }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Title can't be blank")
    end

    it "rejects upload without a file" do
      post "/api/ebooks", params: { ebook: { title: "No File", file_type: "pdf" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end

    it "rejects a declared file_type that doesn't match the real file content" do
      post "/api/ebooks", params: {
        ebook: { title: "Mismatched", file_type: "epub", file: sample_pdf }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/ebooks/:id/download" do
    it "redirects to the file blob for download" do
      ebook = create(:ebook)
      get "/api/ebooks/#{ebook.id}/download"

      expect(response).to have_http_status(:found)
    end

    it "returns 404 when the ebook doesn't exist" do
      get "/api/ebooks/999999/download"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/ebooks/:id" do
    it "deletes the ebook" do
      ebook = create(:ebook)

      expect {
        delete "/api/ebooks/#{ebook.id}"
      }.to change(Ebook, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 when deleting a missing ebook" do
      delete "/api/ebooks/999999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
