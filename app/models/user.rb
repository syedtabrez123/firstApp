class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable, :omniauth_providers => [:facebook, :twitter]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  cattr_accessor :current
  # attr_accessible :title, :body

  has_many :authentications
  has_one :profile, :dependent => :destroy
  has_many :albums, :dependent => :destroy

   def self.facebook_oauth(auth, signed_in_resource=nil)
    member = Authentication.where(:provider => auth.provider, :uid => auth.uid).first
    if member.blank?
      user = User.new(email: auth.info.email, password: Devise.friendly_token[0,20])
      user.skip_confirmation!
      user.save
      user.authentications.create(provider: auth.provider, uid: auth.uid)
      profile_info = fetch_fb_info(auth)
      profile = user.build_profile(profile_info)
      if profile.save
        if profile.dob.present?
          profile.update_attributes(:age => calculate_age(profile.dob))
        end
      end
      user
    else
      User.find(member.user_id)
    end
  end

  def self.calculate_age(age)
    ((DateTime.now - age.to_date) / 365.25).to_i
  end

  def self.fetch_fb_info(auth)
    profile = {}
    profile.merge!(dob: format_date(auth.extra.raw_info.birthday)) if auth.extra.raw_info.birthday.present?
    profile.merge!(first_name: auth.extra.raw_info.first_name) if auth.extra.raw_info.first_name.present?
    profile.merge!(last_name: auth.extra.raw_info.last_name) if auth.extra.raw_info.last_name.present?
    profile.merge!(gender: check_gender(auth.extra.raw_info.gender)) if auth.extra.raw_info.gender.present?
    profile.merge!(city: get_city(auth.info.location)) if auth.info.location.present?
    profile.merge!(avatar: auth.info.image) if auth.info.image.present?
    profile
  end

  def self.format_date(date)
    Date.strptime(date,"%m/%d/%Y")
  end

  def self.check_gender(gender)
    (gender == "male") ? "M" : "F"
  end
  
  def self.get_city(location)
    location.try(:split, ",").try(:first)
  end
  
  def self.twitter_oauth(auth, signed_in_resource=nil)
    member = Authentication.where(:provider => auth.provider, :uid => auth.uid).first
    if member.blank?
      email = auth.info.nickname + "@myalbum.com"
      user = User.new(email: email, password: Devise.friendly_token[0,20])
      user.skip_confirmation!
      user.save
      user.authentications.create(provider: auth.provider, uid: auth.uid)
      user
    else
      User.find(member.user_id)
    end
  end

end
