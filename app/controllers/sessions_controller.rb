# inspired by: http://jessehowarth.com/2011/04/27/ajax-login-with-devise
# used to log in via ajax.  But doesn't replace the normal devise controller for normal logins
class SessionsController < Devise::SessionsController
  def create
    if request.xhr?
      self.resource = warden.authenticate!(auth_options)
      Rails.logger.info "Signed in user #{resource.to_log} via ajax"
      sign_in(resource_name, resource)
      render :json=>{:id=>resource.id, :email=>resource.email, :remaining_points=>resource.remaining_points, :plan_points=>resource.plan_points}
    else
      super
    end
  end
  
  def new
    redirect_to new_user_registration_path
  end
end