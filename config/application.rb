begin
  File.open(".env").each_line do |line|  
    tokens = line.split("=")
    if tokens.length > 0 && !tokens[1].nil? && !tokens[0].nil?
      ENV[tokens[0].strip] ||= tokens[1].strip.chomp
    end
  end
rescue
  puts "couldn't find a file .env to source variables from"
end

ENV['DATA_ENCRYPT_KEY'] ||= 'secret'

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

PRIORITY_SIGNUP=0
PRIORITY_INTERACTIVE=1
PRIORITY_EMAILS=4
PRIORITY_DEFAULT=5
PRIORITY_WEBHOOKS=6
PRIORITY_ANALYTICS=8
PRIORITY_TRIVIAL=10

module RetentionfactoryEngine
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    
  config.assets.initialize_on_precompile = false
  config.assets.precompile += %w( rf_analytics.js edit_account.js edit_organization.js )

    
  config.autoload_paths  += %W(#{config.root}/lib)
  config.autoload_paths += Dir["#{config.root}/lib/**/"]    
    
  config.filter_parameters += [:password]

  Delayed::Worker.default_priority = PRIORITY_DEFAULT
  end
end

#from https://gist.github.com/t2/1464315 and http://stackoverflow.com/questions/5267998/rails-3-field-with-errors-wrapper-changes-the-page-appearance-how-to-avoid-t and http://stackoverflow.com/questions/12252286/how-to-change-the-default-rails-error-div-field-with-errors
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
 html = %(<div class="field_with_errors has-error">#{html_tag}</div>).html_safe
 # add nokogiri gem to Gemfile
 elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, input"
 elements.each do |e|
   if e.node_name.eql? 'label'
     html = %(<div class="clearfix has-error">#{e}</div>).html_safe
   elsif e.node_name.eql? 'input'
     if instance.error_message.kind_of?(Array)
       html = %(<div class="clearfix has-error">#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message.join(',')}</span></div>).html_safe
     else
       html = %(<div class="clearfix has-error">#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message}</span></div>).html_safe
     end
   end
 end
 html
end