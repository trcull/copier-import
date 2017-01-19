class AlertsController < ApplicationController
  before_filter :authenticate_user!, except: [:notifications]
  before_filter :check_signup_complete!, except: [:notifications]
  
  # GET /alerts
  # GET /alerts.json
  def index
    
    @alerts = Alert.where(:acknowledged => false, :user_id => current_user.id).order(:created_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @alerts }
    end
  end

  # GET /alerts/notifications
  # GET /alerts/notifications.json
  def notifications
    if current_user
      @alerts = Alert.where(:acknowledged => false, :user_id => current_user.id).order(:created_at)
      alert_ids = @alerts.collect {|a| a.id}
      @alerts_key = alert_ids.join("-")
    else
      @alerts = []
    end
    respond_to do |format|
      format.html {render :layout => false}
      format.json { render json: @alerts }
    end
  end

  
  # POST /alerts/1/ack
  # POST /alerts/1/ack.json
  def acknowledge
    success = false
    errors = {}
    begin
      @alert = Alert.find(params[:id])
      success = @alert.acknowledge
      errors.merge(@alert.errors)
    rescue Exception => e
      errors = {"error" => e.inspect}
      success = false
    end
      
    respond_to do |format|
      if success 
        format.html { redirect_to :action=> "index" }
        format.json { render json: @alert }
      else
        format.html { redirect_to :action=> "index", notice: 'Alert update failed.' }
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end
end
