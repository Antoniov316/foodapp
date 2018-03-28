class PagesController < ApplicationController
  def home
    @foods = Food.where(active: true).limit(3)
  end


  def search
    # STEP 1
    if params[:search].present? && params[:search].strip != ""
      session[:loc_search] = params[:search]
    end

    # STEP 2
    if session[:loc_search] && session[:loc_search] != ""
      @foods_address = Food.where(active: true).near(session[:loc_search], 20, order: 'distance') rescue []
    else
      @foods_address = Food.where(active: true).all
    end

    # STEP 3
    if @foods_address.present?
      @search = @foods_address.ransack(params[:q]) 
      @foods = @search.result
    else
      @search = Food.ransack(params[:q]) 
      @foods = []
    end  

    @arrFoods = @foods.to_a
  end

  def home_3
    @foods = Food.where(active: true).limit(4)
    render layout: 'home'
  end  
end
