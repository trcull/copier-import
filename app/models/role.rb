class Role < ActiveRecord::Base
  has_and_belongs_to_many :permissions#, :through=>:role_permissions
  
  def add_permission!(permission)
    p = Permission.where(:name=>permission).first
    self.permissions << p
    self.save!
  end
  
  def self.add_permission_to_role(permission, role)
    Role.where(:name=>role).first.add_permission!(permission)
  end
end