class DocumentDictionary < ApplicationRecord
  belongs_to :document
  belongs_to :dictionary
end
