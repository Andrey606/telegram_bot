class Dictionary < ApplicationRecord
  validates :word, uniqueness: true

  # has_many :user_words
  # has_many :users, through: :user_words

  has_many :document_dictionaries
  has_many :documents, through: :document_dictionaries

  scope :translate, ->(word) { where(word: word).first.translation }
end
