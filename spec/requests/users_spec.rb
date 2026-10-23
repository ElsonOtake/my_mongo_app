require "rails_helper"

RSpec.describe "Users API", type: :request do
  it "creates a user" do
    expect {
      post "/users",
           params: {
             user: { name: "Ana", email: "ana@example.com", age: 30 }
           },
           as: :json
    }.to change(User, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body["email"]).to eq("ana@example.com")
  end

  it "returns validation errors" do
    post "/users",
         params: { user: { name: "", email: "" } },
         as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body["errors"]).to be_present
  end
end
