class EvaluationCriterion < ApplicationRecord
  self.table_name = "evaluation_criteria"

  belongs_to :company

  validates :tag_name, presence: true
  validates :description, presence: true

  scope :active, -> { where(is_active: true) }
end
