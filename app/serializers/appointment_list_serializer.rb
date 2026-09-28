class AppointmentListSerializer
  include ALBA::Resource

  attributes :id, :scheduled_at, :duration, :status, :price_cents, :created_at, :updated_at

  attribute :price do |appointment|
    appointment.price_cents / 100
  end

  attribute :ends_at do |appointment|
    appointment.ends_at.iso8601
  end


  association :practitioner_profile, key: :practitioner do |appointment|
    {
      id: appointment.practitioner_profile.id,
      full_name: appointment.practitioner_profile.full_name,
    }
  end
  association :patient_profile, key: :patient do |appointment|
    {
      id: appointment.patient_profile.id,
      full_name: appointment.patient_profile.full_name,
    }
  end
end