require 'ruby-freshbooks'

# common controller for all freshbooks controllers
# observed bugs:
#  1) invoice line items don't have a time_entry_id or expense_id, even when generated from them
#  2) the 'rate' element of an Admin staff member is always blank.  Also, on the web interface it always shows as $0.00
#  3) contractors aren't returned in staff.list, but they are findable by staff.get
class Fb::FbController < ApplicationController
  before_filter :authenticate_user!  
  before_filter :check_fb_token!
  
  def check_fb_token!
    rv = true
    if !Fb::RfApi.has_authorized?(current_user)
      redirect_to '/fb/accounts/connect_account'
      rv = false 
    end
    rv
  end

  def set_sub_menu
    @sub_menu = "fb"
  end
  
  def to_map_by(key, an_array)
    rv = {}
    an_array.each do |elem|
      rv[elem[key]] = elem
    end
    return rv
  end
  

end