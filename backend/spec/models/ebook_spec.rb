require "rails_helper"

RSpec.describe Ebook, type: :model do
  it "is valid with a title, type, and attached file" do
    ebook = build(:ebook)
    expect(ebook).to be_valid
  end

  it "is invalid without a title" do
    ebook = build(:ebook, title: nil)
    expect(ebook).not_to be_valid
    expect(ebook.errors[:title]).to include("can't be blank")
  end

  it "is invalid without an attached file" do
    ebook = build(:ebook)
    ebook.file = nil
    expect(ebook).not_to be_valid
    expect(ebook.errors[:file]).to be_present
  end

  it "rejects a file type outside the allowed list" do
    ebook = build(:ebook, file_type: "exe")
    expect(ebook).not_to be_valid
    expect(ebook.errors[:file_type]).to include("is not included in the list")
  end

  it "rejects a file whose content type does not match declared file_type" do
    ebook = build(:ebook, file_type: "epub") # attached fixture is a real PDF
    expect(ebook).not_to be_valid
    expect(ebook.errors[:file]).to be_present
  end

  it "auto-fills upload_date on create" do
    ebook = create(:ebook)
    expect(ebook.upload_date).to be_present
  end

  it "auto-derives file_size from the attached blob" do
    ebook = create(:ebook)
    expect(ebook.file_size).to eq(ebook.file.blob.byte_size)
  end

  describe ".search_by" do
    it "finds ebooks by partial, case-insensitive title match" do
      match = create(:ebook, title: "Ruby on Rails Guide")
      create(:ebook, title: "Flutter Basics")

      results = Ebook.search_by("rails")
      expect(results).to include(match)
      expect(results.count).to eq(1)
    end

    it "finds ebooks by author" do
      match = create(:ebook, author: "Jane Doe")
      create(:ebook, author: "John Smith")

      results = Ebook.search_by("Jane")
      expect(results).to include(match)
    end

    it "returns all ebooks when query is blank" do
      create_list(:ebook, 2)
      expect(Ebook.search_by("").count).to eq(2)
    end

    it "returns empty when nothing matches" do
      create(:ebook, title: "Something")
      expect(Ebook.search_by("zzz_no_match")).to be_empty
    end
  end
end
