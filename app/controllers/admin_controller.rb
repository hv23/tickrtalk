class AdminController < ApplicationController
  before_filter :require_admin_user
  layout "home"
  
  def index 
    @users = User.paginate(:page => params[:page], :per_page => 25, :order => "username")
    
    @admin = Admin.first
    
    if !@admin.nil?
      @big_game = Game.find(@admin.big_game_id)
    else
      @big_game = nil
    end
  end
  
  def twitter_lists
    if params[:sport]
      @lists = TwitterList.paginate(:page => params[:page], :per_page => 25, :sport => params[:sport], :order => "user")
    else
      @lists = TwitterList.paginate(:page => params[:page], :per_page => 25, :order => "sport")
    end
  end
  
  def add_twitter_list
    @lists = TwitterList.all
    @users = @lists.collect(&:user)
    @sports = @lists.collect(&:sport)
    @list = TwitterList.new(:user => params[:user], :sport => params[:sport])
    
    if @users.include?(params[:user]) && @sports.include?(params[:sport])
      flash[:notice] = "This Twitter user already exists."
      redirect_to :action => "twitter_lists"
    else
      @list.save
      flash[:notice] = "Twitter user has been added."
      redirect_to :action => "twitter_lists"
    end    
  end
end
