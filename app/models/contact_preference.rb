class ContactPreference < ActiveRecord::Base
  belongs_to :customer
  belongs_to :msg_template
  belongs_to :msg_category
end