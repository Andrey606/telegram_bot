class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :file_name
      t.string :mime_type
      t.string :file_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
