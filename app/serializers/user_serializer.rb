class UserSerializer
  include Alba::Resource

  attributes :id, :email, :role, :created_at

  attribute :profile_id do |user|
    user.patient_profile&.id || user.practitioner_profile&.id
  end
end
