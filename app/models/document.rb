class Document < ApplicationRecord
  belongs_to :user
  validates :file_id, uniqueness: true

  has_many :document_dictionaries
  has_many :dictionaries, through: :document_dictionaries

  scope :word_list, -> (user) do
    document_id = Setting.find(user.current_setting_id).document_id
    document = Document.find(document_id)
    document.dictionaries.sort_by {|word| word.word.capitalize }.map {|word| word.word }
  end
end
