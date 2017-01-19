
class Admin::AdminController < ApplicationController
  def check_can_configure_system!
     if !current_user.can?(:configure_system)
       redirect_to "/"
       flash[:notice] = "You are forbidden from doing that"
     end
  end
end