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
      @foods_address = Food.where(active: true).near(session[:loc_search], 20, order: 'distance')
    else
      @foods_address = Food.where(active: true).all
    end

    # STEP 3
    @search = @foods_address.ransack(params[:q])
    @foods = @search.result

    @arrFoods = @foods.to_a

  



    end


end
