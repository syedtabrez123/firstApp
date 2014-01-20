class AuthenticationsController < ApplicationController

  def facebook
    @user = User.facebook_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def twitter
    @user = User.twitter_oauth(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def facebook_registration
    data = decode_facebook_hash(params[:signed_request])
    member = Authentication.where(:provider => "facebook", :uid => data['user_id']).first
    if member.blank?
      user = User.new(email: data['registration']['email'], password: data['registration']['password'])
      user.skip_confirmation!
      user.save
      user.authentications.create(provider: "facebook", uid: data['user_id'])
      user_info = get_user_info(data)
      profile = user.build_profile(user_info)
      if profile.save
        if profile.dob.present?
          profile.update_attributes(:age => User.calculate_age(profile.dob))
        end
      end
      if user.persisted?
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect user, :event => :authentication
      else
        session["devise.twitter_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    else
      flash[:notice] = "You have already Registered. Please try to Sign in."  
      redirect_to "/"
    end
  end

  def get_user_info(data)
    profile = {}
    profile.merge!(dob: User.format_date(data['registration']['birthday'])) if data['registration']['birthday'].present?
    profile.merge!(first_name: data['registration']['first_name']) if data['registration']['first_name'].present?
    profile.merge!(last_name: data['registration']['last_name']) if data['registration']['last_name'].present?
    profile.merge!(gender: User.check_gender(data['registration']['gender'])) if data['registration']['gender'].present?
    if data['registration']['location'].present?
      profile.merge!(city: User.get_city(data['registration']['location']['name'])) if data['registration']['location']['name'].present?
    end
    profile
  end

  def decode_facebook_hash(signed_request)
    signature, str = signed_request.split('.')
    str += '=' * (4 - str.length.modulo(4))
    ActiveSupport::JSON.decode(Base64.decode64(str.gsub("-", "+").gsub("_", "/")))
  end

end
