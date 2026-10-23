class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :age, type: Integer

  has_many :posts, dependent: :destroy

  embeds_many :addresses

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  index({ email: 1 }, { unique: true })
end
