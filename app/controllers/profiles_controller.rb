class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_current_user

  def index
    @profile = @user.profile
  end

  def new
    @profile = @user.build_profile
  end

  def create
    @profile = @user.build_profile(params[:profile])
    if @profile.save
      @profile.update_attributes(:age => User.calculate_age(@profile.dob))
      redirect_to profiles_path
    else
      render :new
    end
  end

  def edit
    @profile = @user.profile
  end

  def update
    @profile = @user.profile
    if @profile.update_attributes(params[:profile])
      @profile.update_attributes(:age => User.calculate_age(@profile.dob))
      redirect_to profiles_path
    else
      render :edit
    end
  end


private
  
  def get_current_user
    @user = current_user
  end

end
