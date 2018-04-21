class UsersController < ApplicationController
  include Orderable
  before_action :authenticate_user!, except: [:show]

  def index
    @users = User.except_user(current_user)
    @message = Message.new
  end

  def show
    @user = User.find(params[:id])
    @foods = @user.foods

    # Displays all the foodie's reviews to the chef (If this user is a chef)
    @foodie_reviews = Review.where(type: "FoodieReview", chef_id: @user.id)

    # Displays all the chef's reviews to the chef (If this user is a foodie)
    @chef_reviews = Review.where(type: "ChefReview", foodie_id: @user.id)

  end

  def update_phone_number
    current_user.update_attributes(user_params)
    current_user.generate_pin
    current_user.send_pin

    redirect_to edit_user_registration_path, notice: "Saved..."
  rescue Exception => e
    redirect_to edit_user_registration_path, alert: "#{e.message}"
  end

  def verify_phone_number
    current_user.verify_pin(params[:user][:pin])

    if current_user.phone_verified
      flash[:notice] = "Your phone number is verified."
    else
      flash[:alert] = "Cannot verify your phone number."
    end

    redirect_to edit_user_registration_path

  rescue Exception => e
    redirect_to edit_user_registration_path, alert: "#{e.message}"
  end

  def payment
  end

  def payout
    if !current_user.merchant_id.blank?
      account = Stripe::Account.retrieve(current_user.merchant_id)
      @login_link = account.login_links.create()
    end
end

def add_card

  
  if current_user.stripe_id.blank?
    customer = Stripe::Customer.create(
      email: current_user.email
    )
    current_user.stripe_id = customer.id
    current_user.save
  else
    customer = Stripe::Customer.retrieve(current_user.stripe_id)
  end


  month, year = params[:expiry].split(/ \/ /)
  new_token = Stripe::Token.create(:card => {
      :number => params[:number],
      :exp_month => month,
      :exp_year => year,
      :cvc => params[:cvv]

    })
    customer.sources.create(source: new_token.id)

    flash[:notice] = "Your card is saved."
    redirect_to payment_method_path
rescue Stripe::CardError => e
    flash[:alert] = e.message
    redirect_to payment_method_path
end


def process_payment 

  session[:cart_obj].each do |obj|
    logger.info obj.inspect
  end
   session[:card_params] = params
  customer = nil
  if current_user.stripe_id.blank?
    customer = Stripe::Customer.create(
      email: current_user.email
    )
    current_user.stripe_id = customer.id
    current_user.save 
  else
    customer = Stripe::Customer.retrieve(current_user.stripe_id)
  end  
 
  @error = ""
  begin
    # new_token = Stripe::Token.create(:card => card_params )
    # customer.sources.create(source: new_token.id)   
    rescue Stripe::CardError => e 

      flash.alert = e.message
      @error = e.message
      flash[:alert] = e.message
    redirect_to payment_method_path
    end

    if @error.blank?
      charge = execute_stripe_payment
      sellers = get_sellers
      execute_transfer_payment(charge.id, sellers)
 
      if @error == ""  
        total_price = get_total_amount/100
        order = Order.new(user_id: current_user.id, price: total_price, status: "Approved", stripe_id: charge.id)
        order.save!

        session[:cart_obj].each do |obj|
          total_days = (obj.fetch("end_date").to_date - obj.fetch("start_date").to_date).to_i + 1
          total_price = total_days * obj.fetch("per_day_qty").to_f * obj.fetch("unit_price").to_f
          order_item =  OrderFood.new(order_id: order.id, food_id: obj.fetch("food_id"), quantity_per_day: obj.fetch("per_day_qty"), price: total_price, 
                                start_date:  obj.fetch("start_date").to_date , end_date: obj.fetch("end_date").to_date )
          order_item.save!
        end
        order.send_notification_to_sellers
        session[:cart_obj] = nil
        session[:card_params] = nil
        redirect_to '/payment-thanks'
      end
    end 
end

  def thanks

  end

  def followed
    followed_user = Follower.where(user_id: params[:user_id], follower_id: current_user.id).first
    if followed_user.present?
      if followed_user.status == true
        followed_user.update(status: false)
        flash[:error] = "Unfollowed Successfully"
      else
        followed_user.update(status: true)
        flash[:success] = "Successfully Following"
      end 
    else 
      follow = Follower.create(user_id: params[:user_id], follower_id: current_user.id, status: true)
      flash[:success] = "Successfully Following"
    end
    redirect_to :back
  end  



  private


    def get_total_amount
    sub_total = 0
    if session[:cart_obj] && session[:cart_obj].size > 0
      session[:cart_obj].each do |d|
        sub_total += d.fetch("price").to_f
      end
    end
    return (sub_total*100).to_i
  end

    def user_params
      params.require(:user).permit(:phone_number, :pin)
    end

    def card_params
      month, year = params[:expiry].split(/ \/ /)      
      card = { number: params[:number], exp_month: month, exp_year: year, cvc: params[:cvv]}
      return card
    end

end
