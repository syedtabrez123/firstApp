class VenuesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @venues = Venue.all
  end
  
  def new
    @venue = Venue.new
    if params['f'].present?
      render :layout => false
    end
  end

  def create
    @venue = Venue.new(params[:venue])
    if @venue.save
      if params['redirect'].present?
         @locations = Venue.all.collect(&:name).uniq
          @album = Album.new
          3.times do
            @album.images.build
          end
        redirect_to new_album_path(:venue => @venue.name)
      else
        redirect_to venues_path
      end
    else
      render :new
    end
  end

  def edit
    @venue = Venue.find(params[:id])
  end

  def update
    @venue = Venue.find(params[:id])
    if @venue.update_attributes(params[:venue])
      redirect_to venues_path
    else
      render :edit
    end
  end

end
