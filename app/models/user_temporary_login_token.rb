
class UserTemporaryLoginToken < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id, :token, :expires_at
end