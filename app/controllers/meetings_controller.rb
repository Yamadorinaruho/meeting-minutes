class MeetingsController < ApplicationController
  before_action :require_profile!
  before_action :set_meeting, only: [:show, :destroy]

  def index
    @meetings = current_profile.company.meetings
                               .includes(:evaluator, :evaluatee, :analysis_result)
                               .order(created_at: :desc)
  end

  def show
  end

  def new
    @meeting = Meeting.new
    load_form_data
  end

  def create
    @meeting = Meeting.new(meeting_params)
    @meeting.company = current_profile.company
    @meeting.uploaded_by = current_profile
    @meeting.speaker_a = @meeting.evaluator
    @meeting.speaker_b = @meeting.evaluatee

    if params[:meeting][:audio_file].present?
      @meeting.original_filename = params[:meeting][:audio_file].original_filename
      @meeting.audio_file.attach(params[:meeting][:audio_file])
    end

    if @meeting.save
      AnalyzeMeetingJob.perform_later(@meeting.id, current_profile.id)
      redirect_to @meeting, notice: "音声ファイルをアップロードしました。AI解析を開始します..."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @meeting.destroy
    redirect_to meetings_path, notice: "会議記録を削除しました"
  end

  private

  def set_meeting
    @meeting = current_profile.company.meetings.find(params[:id])
  end

  def meeting_params
    params.require(:meeting).permit(:evaluator_id, :evaluatee_id)
  end

  def load_form_data
    @profiles = current_profile.company.profiles
    @evaluation_criteria = current_profile.company.evaluation_criteria.active
  end
end
