class CreateEbooks < ActiveRecord::Migration[7.1]
  def change
    create_table :ebooks do |t|
      t.string :title, null: false
      t.string :author
      t.string :file_type, null: false      # "pdf" or "epub"
      t.bigint :file_size, null: false       # bytes, denormalized for fast listing
      t.datetime :upload_date, null: false

      t.timestamps
    end

    add_index :ebooks, :title
    add_index :ebooks, :author
  end
end
