class ChangeStepForUser < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :step, :integer
  end
end
