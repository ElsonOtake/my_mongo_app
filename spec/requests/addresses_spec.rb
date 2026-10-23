require "rails_helper"

RSpec.describe "Addresses management", type: :request do
  let!(:user) { User.create!(name: "Ana", email: "ana@example.com") }

  it "creates, lists, displays, edits, and deletes a user's address" do
    get user_addresses_path(user)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No addresses yet")

    get new_user_address_path(user)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('name="address[city]"')

    post user_addresses_path(user), params: { address: { street: "Main Street", city: "São Paulo" } }
    record = user.reload.addresses.first
    expect(record).to be_present
    expect(response).to redirect_to(user_address_path(user, record))
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("<script>alert(1)</script>")

    get user_addresses_path(user)
    expect(response).to have_http_status(:ok)
    get edit_user_address_path(user, record)
    expect(response).to have_http_status(:ok)

    patch user_address_path(user, record), params: { address: { city: "Campinas" } }
    expect(response).to redirect_to(user_address_path(user, record))
    expect(user.reload.addresses.find(record.id).city).to eq("Campinas")

    delete user_address_path(user, record)
    expect(response).to redirect_to(user_addresses_path(user))
    expect(user.reload.addresses.count).to eq(0)
  end

  it "does not allow another user's address to be read, updated, or deleted" do
    other_user = User.create!(name: "Other", email: "other@example.com")
    record = other_user.addresses.create!({ street: "Main Street", city: "São Paulo" })

    get user_address_path(user, record)
    expect(response).to have_http_status(:not_found)
    patch user_address_path(user, record), params: { address: { city: "Campinas" } }
    expect(response).to have_http_status(:not_found)
    delete user_address_path(user, record)
    expect(response).to have_http_status(:not_found)
    expect(other_user.reload.addresses.count).to eq(1)
  end
end
