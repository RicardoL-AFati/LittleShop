class UsersController < ApplicationController
  before_action :require_default
  skip_before_action :require_default, only: [:new, :create]
  

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Party in my plants! You're a new user! 💐 🌝"
      redirect_to profile_path
    else
      flash.keep[:email_error] = "Whoops! Cannot repeat email address! 🥀"
      render :new

    end
  end

  def show
    @user = current_user || User.find(session[:user_id])
  end

  def current_default?
    current_user && current_user.default?
  end

  def require_default
    render file:'/public/404' unless current_default?
  end

  private
  
  def user_params
    params.require(:user).permit(:name, :password, :email, :address, :city, :state, :zip)
  end

end
