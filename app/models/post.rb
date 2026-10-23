class Post
  include Mongoid::Document

  field :title, type: String
  field :content, type: String

  belongs_to :user
end
