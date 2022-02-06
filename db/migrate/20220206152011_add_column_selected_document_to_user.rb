class AddColumnSelectedDocumentToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :document, index: true
  end
end
