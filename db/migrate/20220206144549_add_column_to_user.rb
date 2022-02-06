class AddColumnToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :words_per_week, :integer
  end
end
