
class SplashController < ApplicationController
  before_filter :authenticate_user_from_token!

  def index
    if current_user.present?
      redirect_to '/fb/xerox_invoice'
    end
  end
  
  def plans_and_pricing
    suppress_login
    @plans = Plan.display_order
  end
  
  def recurly_success
    account_code = params[:account_code]
    #strip the prefix off the user id
    user_id = account_code.delete(Rails.configuration.recurly_user_account_prefix)
    
    Rails.logger.info("[NOTIFY] Got recurly callback for account code #{account_code} and user id #{user_id}")
    @user = User.find(user_id)
    raise "unauthorized user" if @user != current_user
    plan_id = params[:plan_code]
    if not Recurly::ApiHelper.active_plan?(@user.payment_provider_id, plan_id)
      raise "Could not verify recurly plan #{plan_id} as active for #{@user.to_log}/#{@user.payment_provider_id}"
    end
    _cancel_old_plans()

    plan = Plan.where(:payment_provider_id=>plan_id).first
    Rails.logger.info("Adding new plan #{plan.id}/#{plan.payment_provider_id} to user #{@user.to_log}")
    @user.plans << plan 
    @user.save!
    flash[:notice] = "Successfully subscribed to plan '#{plan.name}'"

    # determine if there was a path saved from subscribing
    redirectPath = session[:subscribe_path]
    if redirectPath
      session[:subscribe_path] = nil
      redirect_to redirectPath
    else
      @plans = Plan.display_order
      redirect_to '/'
    end
  end
  
  def signup_cancel
    @plans = Plan.display_order
    render :template=>'/splash/plans_and_pricing'  
  end
  
  def _cancel_old_plans
    old_plans = @user.plans.select{|i|i.group == Plan::GROUP_PAID_PLAN}
    recurly_plans = Recurly::ApiHelper.get_active_plans(@user.payment_provider_id)
    old_plans.each do |old_plan|
      Rails.logger.info("Removing old plan #{old_plan.id}/#{old_plan.payment_provider_id} from user #{@user.to_log}")
      plans_to_cancel = recurly_plans.select {|p| p.plan_code == old_plan.payment_provider_id}
      plans_to_cancel.each do |cancel_me|
        begin
          cancel_me.terminate(:partial)
        rescue => e
          #if the plan is still in a trial period, then cancelling iwth partial fails.  So try it with none instead
          cancel_me.terminate(:none)
        end
      end
      @user.plans.delete old_plan
    end
  end
  
end