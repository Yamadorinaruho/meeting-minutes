class AnalysisResult < ApplicationRecord
  belongs_to :meeting
  belongs_to :analyzed_by, class_name: "Profile"

  def summary
    ai_output&.dig("summary")
  end

  def evaluation_tags
    ai_output&.dig("evaluation_tags") || []
  end

  def score_by_tag
    ai_output&.dig("score_by_tag") || {}
  end

  def next_steps
    ai_output&.dig("next_steps") || []
  end
end
