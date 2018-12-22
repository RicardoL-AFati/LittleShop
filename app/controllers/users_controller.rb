class UsersController < ApplicationController
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

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    params[:user].each do |attribute, value|
      next if value.blank? || @user[attribute] == value
      @user[attribute] = value unless attribute =~ /password/
      @user.password = value if attribute =~ /password/
    end
    @user.save
    redirect_to profile_path
  end

  private
  def user_params
    params.require(:user).permit(:name, :password, :email, :address, :city, :state, :zip)
  end
end
