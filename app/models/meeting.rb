class Meeting < ApplicationRecord
  belongs_to :company
  belongs_to :evaluator, class_name: "Profile"
  belongs_to :evaluatee, class_name: "Profile"
  belongs_to :speaker_a, class_name: "Profile"
  belongs_to :speaker_b, class_name: "Profile"
  belongs_to :uploaded_by, class_name: "Profile"

  has_one :analysis_result, dependent: :destroy
  has_one_attached :audio_file

  validates :original_filename, presence: true
end
