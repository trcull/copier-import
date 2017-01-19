
class OrganizationsController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user! 
  before_filter :check_signup_complete!, except: [:select, :update]
  before_filter :logged_in_user_belongs_to_organization!

  def select
    org = Organization.find params[:organization_id]
    Rails.logger.info "Switching #{current_user.to_log} to organization #{org.id}"
    u = current_user
    u.current_organization = org
    u.save!
    session[:organization_id] = org.id
    render json: {:errors=>[],:msg=>"Success"}
  end
  
  def confirm
    #do stuff  
  end
  
  def edit
    #logged_in_user_belongs_to_organizations sets the @org variable as a side effect
  end
  
  def update
    #logged_in_user_belongs_to_organizations sets the @org variable as a side effect
    permitted_attrs = [:name,:store_url,:currency,:store_type,:address,:city,:country,:email,:phone,:state,:postal_code]
    if current_user.can?(:configure_system)
      permitted_attrs = permitted_attrs + [:type,:timezone,:logo_url,:alt_image_1_url,:currency_template_text,:currency_template_html,:is_installed,:is_active]
    end
    update_to = params.require(:organization).permit(permitted_attrs)
    update_to[:is_confirmed] = true
    if @org.update update_to
      respond_to do |format| 
        format.html {
           flash[:info] = "Organization Saved"
           redirect_to '/'
        }
        format.json {
          render :json => {success: true, message: 'Organization Saved', organization: @org}.to_json
        }
      end
    else
      respond_to do |format|
        format.html { render 'update'}
        format.json { render :json => {success: false, message: 'There were errors saving the org', organization: @org, errors: @org.errors}.to_json}
      end
    end
    
  end
end