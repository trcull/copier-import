
class UserSerializer < ActiveModel::Serializer
  attributes :id, :org_name, :email, :plan_bucket, :is_activated, :created_at, :updated_at, :is_disabled, :first_name, :last_name, :needs_to_pay
  has_many :organizations
  has_many :plans
  has_one :current_organization
  
  def plan_bucket
    object.plan_bucket
  end
  
  def is_activated
    rv = false
    if object.current_organization.present?
      rv = object.current_organization.is_active?
    end
    rv
  end
  
  def org_name
    rv = "MISSING!"
    if object.current_organization.present?
      rv = object.current_organization.name
    end
    rv
  end
end