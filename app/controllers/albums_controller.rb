class AlbumsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_current_user

  def index
    @album = @user.album
    unless @album.blank?
      @pictures = @album.images
    end
  end

  def new
    @locations = Venue.all.collect(&:name).uniq
    @album = Album.new
    3.times do
      @album.images.build
    end
  end

  def create
    params['album']['user_id'] = @user.id
    @album = Album.new(params[:album])
    if @album.save
      venue = Venue.where(:name => params[:album][:location]).first
      @album.images.update_all(venue_id: venue.id)
      redirect_to albums_path
    else
      @locations = Venue.all.collect(&:name).uniq
      render :new
    end
  end

  def edit
    @album = Album.find(params[:id])
    @locations = Venue.all.collect(&:name).uniq
    @venue = Venue.find(@album.images.first.venue_id)
  end

  def update
    @album = Album.find(params[:id])
    if @album.update_attributes(params[:album])
      venue = Venue.where(:name => params[:album][:location]).first
      @album.images.update_all(venue_id: venue.id)
      redirect_to albums_path
    else
      @locations = Venue.all.collect(&:name).uniq
      render :edit
    end
  end

private
  
  def get_current_user
    @user = current_user
  end

end
