class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update]
  skip_before_action :require_profile!, only: [:new, :create]

  def show
  end

  def new
    if current_user.profile.present?
      redirect_to meetings_path, notice: "プロフィールは既に作成されています"
      return
    end

    @profile = Profile.new
    @companies = Company.all
  end

  def create
    @profile = current_user.build_profile(profile_params)

    if @profile.save
      redirect_to meetings_path, notice: "プロフィールを作成しました"
    else
      @companies = Company.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @companies = Company.all
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "プロフィールを更新しました"
    else
      @companies = Company.all
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile
    redirect_to new_profile_path, alert: "プロフィールを作成してください" unless @profile
  end

  def profile_params
    params.require(:profile).permit(:name, :role, :job_title, :company_id)
  end
end
