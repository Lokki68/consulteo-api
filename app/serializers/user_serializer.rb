class UserSerializer
  include Alba::Resource

  attributes :id, :email, :role, :created_at

  attribute :profile_id do |user|
    user.profile_completed?
  end
end
