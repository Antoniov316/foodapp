class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable

         validates :fullname, presence: true, length: {maximum: 50}

         has_many :foods
         has_many :orders

         has_many :foodie_reviews, class_name: "FoodieReview", foreign_key: "foodie_id"
         has_many :chef_reviews, class_name: "ChefReview", foreign_key: "chef_id"

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
                   user.skip_confirmation!
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
            from: '+15207624206',
            to: self.phone_number,
            body: "Your pin is #{self.pin}"
          )
        end

        def verify_pin(entered_pin)
          update(phone_verified: true) if self.pin == entered_pin
        end



      end
