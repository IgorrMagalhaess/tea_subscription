require "rails_helper"

RSpec.describe "Tea Subscription Service API", type: :request do
  before do
    @headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  describe "POST /api/v1/customers/:customer_id/subscriptions" do
    context "with valid parameters" do
      it "creates a new subscription for a customer" do
        customer = create(:customer)

        subscription_params = {
          title: "Premium Tea Subscription",
          price: 19.99,
          frequency: "Monthly"
        }

        require 'pry' ; binding.pry
        post "/api/v1/customers/#{customer.id}/subscriptions", params: JSON.generate(subscription_params), headers: @headers

        expect(response).to be_successful
        expect(response.status).to eq(201)
        subscription_response = JSON.parse(response.body, symbolize_names: true)
        expect(subscription_response[:data][:attributes][:title]).to eq(subscription_params[:title])
        expect(subscription_response[:data][:attributes][:price]).to eq(subscription_params[:price])
        expect(subscription_response[:data][:attributes][:frequency]).to eq(subscription_params[:frequency])
      end
    end

    context "with invalid parameters" do
      it "returns 422 Unprocessable Entity" do
        customer = create(:customer)

        subscription_params = {
          title: "",
          price: 19.99,
          frequency: "Monthly"
        }

        post "/api/v1/customers/#{customer.id}/subscriptions", params: JSON.generate(subscription_params), headers: @headers

        expect(response.status).to eq(422)

        error_response = JSON.parse(response.body, symbolize_names: true)
        expect(error_response[:errors]).to include("Title can't be blank")
      end
    end
  end

  describe "DELETE /api/v1/subscriptions/:id" do
    it "cancels a customer's subscription" do
      subscription = create(:subscription)

      delete "/api/v1/subscriptions/#{subscription.id}", headers: @headers

      expect(response).to be_successful
      expect(response.status).to eq(204)

      expect(Subscription.find_by(id: subscription.id)).to be_nil
    end

    it "returns 404 Not Found if subscription does not exist" do
      delete "/api/v1/subscriptions/999", headers: @headers

      expect(response.status).to eq(404)
    end
  end

  describe "GET /api/v1/customers/:customer_id/subscriptions" do
    it "retrieves all subscriptions for a customer" do
      customer = create(:customer) 
      subscriptions = create_list(:subscription, 3, customer: customer)

      get "/api/v1/customers/#{customer.id}/subscriptions", headers: @headers

      expect(response).to be_successful
      expect(response.status).to eq(200)

      subscriptions_response = JSON.parse(response.body, symbolize_names: true)
      expect(subscriptions_response[:data].length).to eq(3)
    end

    it "returns 404 Not Found if customer does not exist" do
      get "/api/v1/customers/999/subscriptions", headers: @headers

      expect(response.status).to eq(404)
    end
  end
end
