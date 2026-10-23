require "rails_helper"

RSpec.describe "Posts management", type: :request do
  let!(:user) { User.create!(name: "Ana", email: "ana@example.com") }

  it "creates, lists, displays, edits, and deletes a user's post" do
    get user_posts_path(user)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No posts yet")

    get new_user_post_path(user)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('name="post[title]"')

    post user_posts_path(user), params: { post: { title: "First post", content: "Hello <script>alert(1)</script>" } }
    record = user.reload.posts.first
    expect(record).to be_present
    expect(response).to redirect_to(user_post_path(user, record))
    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("<script>alert(1)</script>")

    get user_posts_path(user)
    expect(response).to have_http_status(:ok)
    get edit_user_post_path(user, record)
    expect(response).to have_http_status(:ok)

    patch user_post_path(user, record), params: { post: { title: "Updated post" } }
    expect(response).to redirect_to(user_post_path(user, record))
    expect(user.reload.posts.find(record.id).title).to eq("Updated post")

    delete user_post_path(user, record)
    expect(response).to redirect_to(user_posts_path(user))
    expect(user.reload.posts.count).to eq(0)
  end

  it "does not allow another user's post to be read, updated, or deleted" do
    other_user = User.create!(name: "Other", email: "other@example.com")
    record = other_user.posts.create!({ title: "First post", content: "Hello <script>alert(1)</script>" })

    get user_post_path(user, record)
    expect(response).to have_http_status(:not_found)
    patch user_post_path(user, record), params: { post: { title: "Updated post" } }
    expect(response).to have_http_status(:not_found)
    delete user_post_path(user, record)
    expect(response).to have_http_status(:not_found)
    expect(other_user.reload.posts.count).to eq(1)
  end
end
