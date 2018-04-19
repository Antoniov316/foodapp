class Food < ApplicationRecord
  enum instant: {Request: 0, Instant: 1}
  before_save :send_notification_to_follower

  belongs_to :user
  has_many :photos 

  has_many :foodie_reviews
  has_many :calendars 

  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  validates :cuisine_type, presence: true
  validates :entree_type, presence: true
  validates :portions_available, presence: true

  def cover_photo(size)
    if self.photos.length > 0
      self.photos[0].image.url(size)
    else
      "blank.jpg"
    end
  end

  def average_rating
    foodie_reviews.count == 0 ? 0 : foodie_reviews.average(:star).round(2).to_i
  end

  def user_follower
    user.followers.where(status: true)
  end
    
  def send_notification_to_follower
    return unless (self.active_changed? && self.active?)
    user_follower.each do |follower|
      Notification.create!(recipient_id: follower.follower_id ,user_id: self.user.try(:id) ,notification: "food", message: "#{self.try(:user).try(:fullname)} created a new food", food_id: self.id) 
    end  
  end      

end
