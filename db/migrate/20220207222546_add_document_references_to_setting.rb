class AddDocumentReferencesToSetting < ActiveRecord::Migration[7.0]
  def change
    add_reference :settings, :document, index: true
  end
end
