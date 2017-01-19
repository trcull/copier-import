# inspired by: http://jessehowarth.com/2011/04/27/ajax-login-with-devise
# used to log in via ajax.  But doesn't replace the normal devise controller for normal logins
class RegistrationsController < Devise::RegistrationsController
  
  # POST /resource
  def create
    Rails.logger.info "[NOTIFY] Got request to create new account"
    if request.xhr?
      build_resource
      if resource.save
        if resource.active_for_authentication?
          sign_in(resource_name, resource)
          render :json=>{:id=>resource.id, :email=>resource.email}
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          render :json=>{:id=>resource.id, :email=>resource.email}
        end
      else
        clean_up_passwords resource
        render :json=>{:errors=>resource.errors,:id=>resource.id, :email=>resource.email}
      end
    else
      super
    end
    Rails.logger.info "Signup errors where: #{resource.errors.inspect}"
  end  
  
  def update
    super
  end
  
  def new
    suppress_login
    super
  end
end