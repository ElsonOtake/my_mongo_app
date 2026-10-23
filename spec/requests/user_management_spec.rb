require "rails_helper"

RSpec.describe "User management", type: :request do
  it "renders the empty list and the new user form" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No users yet")

    get new_user_path
    expect(response.body).to include('name="user[email]"')
  end

  it "creates, displays, edits, and deletes a user through HTML requests" do
    post users_path, params: { user: { name: "Ana", email: "ana@example.com", age: 30 } }
    user = User.find_by(email: "ana@example.com")
    expect(response).to redirect_to(user_path(user))
    follow_redirect!
    expect(response.body).to include("Ana", "View posts", "View addresses")

    get edit_user_path(user)
    expect(response).to have_http_status(:ok)
    patch user_path(user), params: { user: { name: "Ana Maria" } }
    expect(response).to redirect_to(user_path(user))
    expect(user.reload.name).to eq("Ana Maria")

    user.posts.create!(title: "Example")
    user.addresses.create!(street: "Main Street", city: "São Paulo")
    expect { delete user_path(user) }.to change(User, :count).by(-1).and change(Post, :count).by(-1)
    expect(response).to redirect_to(users_path)
  end

  it "renders validation errors without losing submitted values" do
    post users_path, params: { user: { name: "Ana", email: "" } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Email can&#39;t be blank", 'value="Ana"')

    user = User.create!(name: "Ana", email: "ana@example.com")
    patch user_path(user), params: { user: { name: "" } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(user.reload.name).to eq("Ana")
  end

  it "returns 404 for a missing user" do
    get user_path(BSON::ObjectId.new)
    expect(response).to have_http_status(:not_found)
  end
end
