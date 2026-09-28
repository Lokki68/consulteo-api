class PatientProfileSerializer
  include Alba::Resource

  attributes :id, :first_name, :last_name, :date_of_birth, :phone_number, :address,
             :city, :postal_code, :latitude, :longitude, :created_at, :updated_at

  attribute :full_name do |patient|
    "#{patient.first_name} #{patient.last_name}"
  end

  attribute :age do |patient|
    ((Time.current - patient.date_of_birth.to_time) / 1.year).to_i if patient.date_of_birth.present?
  end

  association :user, key: :user, transform: UserSerializer
end