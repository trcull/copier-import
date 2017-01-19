class Alert < ActiveRecord::Base

  belongs_to :user

  #attr_accessible :acknowledged, :acknowledged_at, :level, :message, :source, :user_id

  def acknowledge
    attrs = {
      :acknowledged => true,
      :acknowledged_at => Time.now()
    }
    self.update_attributes(attrs)
  end
end
