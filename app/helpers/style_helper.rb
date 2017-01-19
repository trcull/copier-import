module StyleHelper
  def resource_error_messages!
    return '' if !defined?(resource) || resource.errors.empty?

    messages = resource.errors.messages.map do |msg|
      if msg[1].length > 0  && (msg[0] == :email || msg[0] == :password || msg[0] == :password_confirmation || msg[0] == :current_password)
        content_tag(:li, "#{msg[0].to_s.try(:humanize)} #{msg[1][0]}")
      elsif msg[1].length > 0   
        content_tag(:li, msg[1][0].to_s.try(:humanize))
      else
          ''
      end 
    end.join
    sentence = I18n.t('errors.messages.not_saved',
      count: resource.errors.count,
      resource: resource.class.model_name.human.downcase)

    html = <<-HTML
    <div class="alert alert-error alert-dismissable">
      <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>      
      #{messages}
    </div>
    HTML

    html.html_safe
  end
end