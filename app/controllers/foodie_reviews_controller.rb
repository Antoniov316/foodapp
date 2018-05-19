class FoodieReviewsController < ApplicationController

  def create
    # Step 1: Check if the reservation exists (food_id, chef_id, chef_id)

    # Step 2: Check if the current chef already reviewed the guest in this reservation.

    # @order = Order.where(
    #                 id: foodie_review_params[:order_id],
    #                 food_id: foodie_review_params[:food_id],

    #                ).first
    @order_food = OrderFood.find_by_id(foodie_review_params[:order_food_id])

    if !@order_food.nil? #&& @order_food.food_id == foodie_review_params[:chef_id].to_i

      @has_reviewed = FoodieReview.where(
                        order_food_id: @order_food.id,
                        chef_id: foodie_review_params[:chef_id]
                      ).first

      if @has_reviewed.nil?
          # Allow to review
          @foodie_review = current_user.foodie_reviews.create(foodie_review_params)
          flash[:success] = "Your Review was created..."
      else
          # Already reviewed
          flash[:success] = "You already reviewed this Order"
      end
    else
      flash[:alert] = "Order not found "
    end

    redirect_back(fallback_location: request.referer)
  end

  def destroy
    @foodie_review = Review.find(params[:id])
    @foodie_review.destroy

    redirect_back(fallback_location: request.referer, notice: "Removed...!")
  end

  private
    def foodie_review_params
      params.require(:foodie_review).permit(:comment, :star, :food_id, :order_id, :chef_id, :order_food_id)
    end
end
