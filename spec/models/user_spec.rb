require "rails_helper"

RSpec.describe User, type: :model do
  it "requires a name" do
    user = User.new(email: "ana@example.com")

    expect(user).not_to be_valid
    expect(user.errors[:name]).to be_present
  end

  it "rejects duplicate email addresses" do
    User.create!(name: "Ana", email: "ana@example.com")

    duplicate = User.new(name: "Another Ana", email: "ana@example.com")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to be_present
  end
end
