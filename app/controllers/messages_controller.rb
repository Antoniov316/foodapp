class MessagesController < ApplicationController
  def new_message
    @user = User.find(params[:id])
    @users = User.except_user(current_user)   
    @chatroom = Chatroom.where("(user_id =? and sender_id= ?) OR (user_id =? and sender_id=?)",@user.id,current_user,current_user,@user.id).first
    @chatroom = @user.chatrooms.create(sender_id: current_user.id) unless @chatroom.present?
    @chatroom.messages.where(sender_id: @user.id, user_id: current_user.id, status: false).update_all(status: true) rescue nil
    @message = Message.new
    @messages = @chatroom.messages.order("id DESC")
    render 'users/index'
  end   

  def create
    @chatroom = Chatroom.find(params[:message][:room_id])
    message = @chatroom.messages.build(body: params[:message][:body],sender_id: current_user.id)
    if message.save
      redirect_to new_message_path(params["user_id"])
    end
  end

  def index
    @chatrooms = Chatroom.where("(user_id =?) OR (sender_id=?)",current_user,current_user)
    @notifications = Notification.where(recipient_id: current_user.id, notification: "food").order("id DESC")
    @unread_notifications = @notifications.where(read: false)
    @unread_notifications_ids = @unread_notifications.pluck(:id)
    @unread_notifications = @unread_notifications.update_all(read: true)
  end

  def read_notification
    @notifications = Notification.where(recipient_id: current_user.id,read: false)
    @notifications.update_all(read: true)    
  end

  def notifications
    @chatrooms = Chatroom.where("(user_id =?) OR (sender_id=?)",current_user,current_user)
    @notifications = Notification.where(recipient_id: current_user.id, notification: "food").order("id DESC")
    @unread_notifications = @notifications.where(read: false)
    @unread_notifications_ids = @unread_notifications.pluck(:id)
    @unread_notifications = @unread_notifications.update_all(read: true)
  end

end
