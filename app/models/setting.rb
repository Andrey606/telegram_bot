class Setting < ApplicationRecord
  belongs_to :user

  # validates :document_id, uniqueness: true
  validates :user_id, uniqueness: { scope: :document_id }

  serialize :planning_day, Array

 
  # enum planning_day: [
  #   :mon,
  #   :tue,
  #   :wed,
  #   :thu,
  #   :fri,
  #   :sat,
  #   :sun
  # ]
end
