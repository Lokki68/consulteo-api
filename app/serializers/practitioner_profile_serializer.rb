class PractitionerProfileSerializer
  include Alba::Resource

  attributes :id, :first_name, :last_name, :bio, :rpps_number, :verified, :sector,
             :consultation_price_cents, :cancellation_deadline_hours, :created_at, :updated_at

  attribute :full_name do |practitioner|
    "#{practitioner.first_name} #{practitioner.last_name}"
  end

  attribute :consultation_price do |practitioner|
    practitioner.consultation_price_cents ? practitioner.consultation_price_cents / 100.0 : nil
  end

  association :user, key: :user, transform: UserSerializer

  association :specialities, key: :specialities do |practitioner|
    practitioner.specialities.map { |s| SpecialitySerializer.new(s).serialize }
  end
end