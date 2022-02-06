class Document < ApplicationRecord
  belongs_to :user
  validates :file_id, uniqueness: true

  has_many :document_dictionaries
  has_many :dictionaries, through: :document_dictionaries
end
