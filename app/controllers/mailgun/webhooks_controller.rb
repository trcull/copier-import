
class Mailgun::WebhooksController < ApplicationController
  def spam
    Rails.logger.info "Mailgun SPAM webhook called with parameters: #{params.inspect}"
    hook = save_raw params
    complaint = Mailgun::SpamComplaint.new
    complaint.raw_webhook = hook
    complaint.save!
    render text: "ok"
  end

  def open
    Rails.logger.info "Mailgun OPEN webhook called with parameters: #{params.inspect}"
    hook = save_raw params
    open = Mailgun::Open.new
    open.raw_webhook = hook
    open.save!
    render text: "ok"
  end

  def click
    Rails.logger.info "Mailgun CLICK webhook called with parameters: #{params.inspect}"
    hook = save_raw params
    click = Mailgun::Click.new
    click.raw_webhook = hook
    click.url_clicked = params[:url]
    click.save!
    render text: "ok"
  end

  def bounce
    Rails.logger.info "Mailgun BOUNCE webhook called with parameters: #{params.inspect}"
    hook = save_raw params
    bounce = Mailgun::Bounce.new
    bounce.raw_webhook = hook
    bounce.smtp_code = params[:code]
    bounce.error_msg = params[:error]
    bounce.save!
    render text: "ok"
  end

  def save_raw(hook_data)
    rv = Mailgun::RawWebhook.new
    rv.parameters = hook_data.inspect
    rv.mailgun_type = hook_data[:event]
    rv.email = hook_data[:recipient]
    data_json = hook_data["my-custom-data"]
    if data_json
      begin
        data = JSON.parse data_json
        rv.site_account_id = data['site_account']
        rv.from = data['from']
        rv.subject = data['subject']
      rescue => e
        msg = "Error trying to parse custom data from Mailgun: #{e.message} with data #{data_json}"
        Rails.logger.error msg
      end
    end
    rv.find_assumed_msg!
    rv.save!
    rv
  end
  

end