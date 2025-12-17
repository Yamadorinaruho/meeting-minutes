class AnalyzeMeetingJob < ApplicationJob
  queue_as :default

  def perform(meeting_id, profile_id)
    meeting = Meeting.find(meeting_id)
    profile = Profile.find(profile_id)

    service = GeminiAnalysisService.new(meeting)
    result = service.analyze

    if result[:error]
      Rails.logger.error "Meeting analysis failed: #{result[:error]}"
      return
    end

    AnalysisResult.create!(
      meeting: meeting,
      analyzed_by: profile,
      ai_output: result[:analysis],
      used_model: "gemini-2.0-flash",
      prompt_used: result[:prompt]
    )
  end
end
