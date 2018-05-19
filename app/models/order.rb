class Order < ApplicationRecord
  enum status: {Waiting: 0, Approved: 1, Declined: 2}

  belongs_to :user 
  has_many :order_foods
  after_create :send_notification_to_buyer

  def send_notification_to_buyer
    begin
    	UserMailer.send_order_email(user_id).deliver_now
      phone_number = user.phone_number
      if phone_number.present?
        @client = Twilio::REST::Client.new
        @client.messages.create(
          from: '+15202146012',
          to: phone_number,
          body: "Thank you for ordering with Panza! Your ordered is being processed and it will be ready shortly."
        )
      end
    rescue 
    end
  end
  
  def send_notification_to_sellers
    begin
      sellers = get_sellers_list
      sellers.each do |user|
        UserMailer.notify_seller(user.id, self.id).deliver_now
        phone_number = user.phone_number
        if phone_number.present?
          @client = Twilio::REST::Client.new
          @client.messages.create(
            from: '+15202146012',
            to: phone_number,
            body: "An Order has been placed for you listing #{get_food_names(user.id)} by #{user.fullname}"
          )
        end
      end
    rescue
    end
  end 

  def get_sellers_list
    user_ids =  order_foods.map(&:food).flatten.compact.map(&:user_id).uniq rescue []
    return User.where(id: user_ids)
  end



  def get_food_names(user_id)
    string = ""
    user = User.find_by_id user_id
    order_foods.where(food_id: user.foods.map(&:id) ).map(&:food).map{|c| string << "#{c.entree_type}, " } 
    return string
  end

  def send_notification_to_food_owner(current_user)
    users =  get_sellers_list
    users.each do |user|
      Notification.create(user_id: current_user.id, recipient_id: user.id , read: false, notification: 'food', order_id: self.id, message: "Order received!!!")
    end
  end
end
