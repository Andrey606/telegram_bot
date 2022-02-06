class CreateDocumentDictionaries < ActiveRecord::Migration[7.0]
  def change
    create_table :document_dictionaries do |t|
      t.references :document, null: false, foreign_key: true
      t.references :dictionary, null: false, foreign_key: true

      t.timestamps
    end
  end
end
