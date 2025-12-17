class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :company

  has_many :meetings_as_evaluator, class_name: "Meeting", foreign_key: "evaluator_id", dependent: :destroy
  has_many :meetings_as_evaluatee, class_name: "Meeting", foreign_key: "evaluatee_id", dependent: :destroy
  has_many :analysis_results, foreign_key: "analyzed_by_id", dependent: :destroy

  validates :name, presence: true
  validates :role, presence: true

  ROLES = %w[admin manager member].freeze

  def display_name
    "#{name} (#{role})"
  end
end
