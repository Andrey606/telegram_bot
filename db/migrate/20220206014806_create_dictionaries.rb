class CreateDictionaries < ActiveRecord::Migration[7.0]
  def change
    create_table :dictionaries do |t|
      t.string :word, foreign_key: true
      t.string :translation
      t.string :parts_of_speech
      t.string :level
      t.json :examples

      t.timestamps
    end
  end
end
