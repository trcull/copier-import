
class Fb::AccountsController < Fb::FbController 
  skip_before_filter :check_fb_token!
  
  def redirect_to_authorize_url(request_token)
    session[:fb_request_token] = request_token
    redirect_to request_token.authorize_url
  end

  def connect_account
    site_account = current_user.account_for("fb")
    if site_account.field1.present? || params[:name].present?
      if params[:name].present?
        site_account.field1 = params[:name]
        site_account.save!
      end
      api = Fb::RfApi.new(site_account)
      begin
        request_token = api.oauth_request_token()
        redirect_to_authorize_url request_token
      rescue => e
        Rails.logger.warn "Caught exception trying to get Freshbooks request token: #{e.message}"
        flash[:error] = "Looks like your Freshbooks site isn't right.  Please try again"
        respond_to do |format|
          format.html
        end
      end
    else
      respond_to do |format|
        format.html
      end
    end
  end
  
  def oauth_callback
    oauth_verifier = params[:oauth_verifier]
    request_token = session[:fb_request_token] || params[:fb_request_token] # this is only ever in the request parameters during unit testing.
    if oauth_verifier.present? && request_token.present?
      begin
        site_account = current_user.account_for("fb")
        api = Fb::RfApi.new(site_account)
        access_token = api.oauth_access_token(request_token, oauth_verifier)
        site_account.token = access_token.token
        site_account.secret = access_token.secret
        site_account.save!
        Fb::RefreshAllClientsJob.enqueue(current_user.id)
      rescue => e
        Rails.logger.error("Failed to oauth authenticate at Freshbooks for user #{current_user.email} with exception: #{e.message}") 
        flash[:error] = "Sorry, looks like Freshbooks authorization failed.  Please try again"
      end
    else
      flash[:error] = "Sorry, looks like Freshbooks authorization failed.  Please try again"
      Rails.logger.error("Failed to get either a verifier code #{oauth_verifier} or a request token #{request_token.inspect}")
    end
    redirect_to '/'
  end
  
end
