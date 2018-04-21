class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

         validates :fullname, presence: true, length: {maximum: 50}

         has_many :foods
         has_many :orders
         has_one :payment_setting
         has_many :foodie_reviews, class_name: "FoodieReview", foreign_key: "foodie_id"
         has_many :chef_reviews, class_name: "ChefReview", foreign_key: "chef_id"
         has_many :messages,dependent: :destroy 
         scope :except_user, ->(current_user) { where.not(id: current_user) }
         has_many :chatrooms
         has_many :notifications, as: :recipient
         has_many :followers
         def self.from_omniauth(auth)
           user = User.where(email: auth.info.email).first

             if user
               return user

             else
                where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
                  user.email = auth.info.email
                  user.password = Devise.friendly_token[0,20]
                  user.fullname = auth.info.name
                  user.image = auth.info.image
                  user.uid = auth.uid
                  user.provider = auth.provider
                  # If you are using confirmable and the provider(s) you use validate emails,
                  # uncomment the line below to skip the confirmation emails.
                   # user.skip_confirmation!
              end
         end
      end

      def generate_pin
          self.pin = SecureRandom.hex(2)
          self.phone_verified = false
          save
        end

        def send_pin
          @client = Twilio::REST::Client.new
          @client.messages.create(
            from: '+15202146012',
            to: self.phone_number,
            body: "Your pin is #{self.pin}"
          )
        end

        def verify_pin(entered_pin)
          update(phone_verified: true) if self.pin == entered_pin
        end

        def stripe_connected?
          payment_setting.blank? ? false : payment_setting.is_stripe_connected?
        end

        def get_account_id
          payment_setting.stripe_user_id rescue nil
        end

        def count_unread_messages
          messages.where(status: false).count rescue 0
        end

        def is_following? user_id
          Follower.where(user_id: user_id, follower_id: id, status: true).present?
        end

      end
