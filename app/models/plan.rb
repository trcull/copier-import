
class Plan < ActiveRecord::Base
  GROUP_PAID_PLAN='paid'
  GROUP_FREE_PLAN='free'
  GROUP_AFFILIATE_PLAN='affiliate'
  GROUP_SPONSORED_PLAN='sponsored'
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :price
  validates_presence_of :points
  validates_presence_of :payment_provider_id
  
  scope :display_order, -> {where('price < ?' , 600).order(:price)}

end