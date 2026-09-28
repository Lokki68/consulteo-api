class UserSerializer
  include Alba::Resource

  attributes :id, :email, :role, :created_at, :updated_at

  attribute :profile_completed do |user|
    user.profile_completed?
  end

  attribute :confirmed do |user|
    user.confirmed_at.present?
  end
end
