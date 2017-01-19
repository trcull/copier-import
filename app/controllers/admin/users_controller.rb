class Admin::UsersController < Admin::AdminController
  before_filter :authenticate_user!
  before_filter :check_can_configure_system!

  def edit
    @user = User.find params[:id]
  end
  
  def index
    @users = User.all.order("created_at desc")
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @users }
    end    
  end
  
  def list
      
  end
  

end