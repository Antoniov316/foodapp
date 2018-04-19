module ApplicationHelper
  def avatar_url(user)
    if user.image
      "http://graph.facebook.com/#{user.uid}/picture?type=large"
    else
    gravatar_id = Digest::MD5::hexdigest(user.email).downcase
      "https://www.gravatar.com/avatar/#{gravatar_id}.jpg?d=identical&s=150"
    end
  end

  def stripe_express_path
    "https://connect.stripe.com/express/oauth/authorize?response_type=code&client_id=ca_By9Zm5U52iH5EfrRjofR49oK8c17vGCs&scope=read_write"

  end

  def get_sub_total
    sub_total = 0
    if session[:cart_obj] && session[:cart_obj].size > 0
      session[:cart_obj].each do |d|
        sub_total += d.fetch("price").to_f
      end
    end
    return sub_total
  end

  def products_in_cart
    return session[:cart_obj] && session[:cart_obj].size > 0
  end
 
  def get_card_number 
    number = "" 
    if session[:card_params]
      number = session[:card_params]["number"] rescue ''
    end
    return number
  end

  def get_card_name
    number = "" 
    if session[:card_params]
      number = session[:card_params]["name"] rescue ''
    end
    return number
  end

  def get_card_cvv
    number = "" 
    if session[:card_params]
      number = session[:card_params]["cvv"] rescue ''
    end
    return number
  end

  def get_card_exp   
    return session[:card_params]["card"]["expiry"] rescue ''
  end
 
  def gravatar_for(user, opts = {})
    opts[:alt] = user.fullname
    image_tag "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}?s=#{opts.delete(:size) { 40 }}",
              opts
  end

  def get_notification_count(current_user) 
    n = Notification.where(recipient_id: current_user.id, read: false).count rescue 0
    m = current_user.messages.where(status: false).count rescue 0
    return (m + n)
  end  
end
