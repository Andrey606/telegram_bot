class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :words_per_week
      t.text :planning_day
      t.time :planning_time

      t.timestamps
    end
  end
end
