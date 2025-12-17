class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :authenticate_user!
  before_action :set_current_profile

  helper_method :current_profile

  private

  def set_current_profile
    return unless user_signed_in?

    @current_profile = current_user.profile
  end

  def current_profile
    @current_profile
  end

  def require_profile!
    return if current_profile.present?

    redirect_to new_profile_path, alert: "プロフィールを作成してください"
  end
end
