class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Mongoid::Errors::DocumentNotFound do
    respond_to do |format|
      format.html { render plain: "Record not found", status: :not_found }
      format.json { render json: { error: "Record not found" }, status: :not_found }
    end
  end
end
