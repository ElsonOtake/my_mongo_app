class Address
  include Mongoid::Document

  field :street, type: String
  field :city, type: String

  embedded_in :user
end
