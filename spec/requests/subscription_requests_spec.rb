require "rails_helper"

RSpec.describe "Tea Subscription Service API", type: :request do
  before do
    @headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  describe "POST /api/v1/customers/:customer_id/subscriptions" do
    describe "with valid parameters" do
      it "creates a new subscription for a customer" do
        customer = create(:customer)

        subscription_params = {
          title: "Premium Tea Subscription",
          price: 19.99,
          frequency: 0
        }

        post "/api/v1/customers/#{customer.id}/subscriptions", params: JSON.generate(subscription: subscription_params), headers: @headers

        expect(response).to be_successful
        expect(response.status).to eq(201)

        subscription_response = JSON.parse(response.body, symbolize_names: true)
        expect(subscription_response[:data][:attributes][:title]).to eq(subscription_params[:title])
        expect(subscription_response[:data][:attributes][:price]).to eq(subscription_params[:price])
        expect(subscription_response[:data][:attributes][:frequency]).to eq("weekly")
        expect(subscription_response[:data][:attributes][:status]).to eq("active")
      end
    end

    describe "with invalid parameters" do
      it "returns 422 Unprocessable Entity" do
        customer = create(:customer)

        subscription_params = {
          title: "",
          price: 19.99,
          frequency: 1
        }

        post "/api/v1/customers/#{customer.id}/subscriptions", params: JSON.generate(subscription: subscription_params), headers: @headers

        expect(response.status).to eq(422)

        error_response = JSON.parse(response.body, symbolize_names: true)

        expect(error_response[:errors]).to be_a(Array)
        expect(error_response[:errors].first[:detail]).to eq("Title can't be blank")
      end
    end
  end

  describe "DELETE /api/v1/customers/:id/subscriptions/:id" do
    it "cancels a customer's subscription" do
      customer = create(:customer)
      subscription = create(:subscription, customer_id: customer.id)

      delete "/api/v1/customers/#{customer.id}/subscriptions/#{subscription.id}", headers: @headers

      expect(response).to be_successful
      expect(response.status).to eq(204)

      expect(Subscription.find_by(id: subscription.id).status).to eq("cancelled")
    end

    it "returns 404 Not Found if customer does not exist" do
      customer = create(:customer)
      subscription = create(:subscription, customer_id: customer.id)

      delete "/api/v1/customers/999999/subscriptions/#{subscription.id}", headers: @headers

      expect(response.status).to eq(404)
      
      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:errors]).to be_a(Array)
      expect(error_response[:errors].first[:detail]).to eq("Couldn't find Customer with 'id'=999999")
    end

    it "returns 404 Not Found if subscription does not exist" do
      customer = create(:customer)
      subscription = create(:subscription, customer_id: customer.id)

      delete "/api/v1/customers/#{customer.id}/subscriptions/99999999", headers: @headers

      expect(response.status).to eq(404)
      
      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:errors]).to be_a(Array)
      expect(error_response[:errors].first[:detail]).to eq("Couldn't find Subscription with 'id'=99999999")
    end
  end

  describe "GET /api/v1/customers/:customer_id/subscriptions" do
    it "retrieves all subscriptions for a customer" do
      customer = create(:customer) 
      subscriptions = create_list(:subscription, 3, customer_id: customer.id)

      get "/api/v1/customers/#{customer.id}/subscriptions", headers: @headers

      expect(response).to be_successful
      expect(response.status).to eq(200)

      subscriptions_response = JSON.parse(response.body, symbolize_names: true)
      expect(subscriptions_response[:data].length).to eq(3)
    end

    it "returns 404 Not Found if customer does not exist" do
      get "/api/v1/customers/9999999/subscriptions", headers: @headers

      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body, symbolize_names: true)

      expect(error_response[:errors]).to be_a(Array)
      expect(error_response[:errors].first[:detail]).to eq("Couldn't find Customer with 'id'=9999999")
    end
  end
end
