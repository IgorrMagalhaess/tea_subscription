class Api::V1::SubscriptionsController < ApplicationController
  before_action :find_customer
  before_action :set_subscription, only: [:destroy]

  def index
    @subscriptions = Subscription.where(customer_id: params[:customer_id])
    render json: SubscriptionSerializer.new(@subscriptions)
  end

  def create
    @customer = Customer.find(params[:customer_id])
    @subscription = @customer.subscriptions.build(subscription_params)

    if @subscription.save
      render json: SubscriptionSerializer.new(@subscription), status: :created
    else
      render json: ErrorSerializer.new(ErrorMessage.new(@subscription.errors.full_messages.first, 422))
      .serialize_json, status: :unprocessable_entity
    end
  end

  def destroy
    @subscription.update(status: "cancelled")
    head :no_content
  end

  private

  def find_customer
    @customer = Customer.find(params[:customer_id])
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:customer_id, :title, :price, :status, :frequency)
  end
end