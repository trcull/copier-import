class Admin::ConfigurationController < Admin::AdminController
  before_filter :authenticate_user!
  before_filter :check_can_configure_system!
  
  def index
    can!(:configure_system)
  end
  
  def panic
    if can!(:panic)
      MsgCategory.all.each do |cat|
        cat.is_disabled = true
        cat.save!
      end
      MsgProvider.all.each do |p|
        p.is_disabled = true
        p.save!
      end
      ENV['PANIC'] = 'true'
    end
  end
  
  def stand_down
    if can!(:panic)
      MsgCategory.all.each do |cat|
        cat.is_disabled = false
        cat.save!
      end
      MsgProvider.all.each do |p|
        p.is_disabled = false
        p.save!
      end
      ENV['PANIC'] = 'false'
    end
  end
end