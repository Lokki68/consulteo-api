class AppointmentSerializer
  include ALBA::Resource

  attributes :id, :scheduled_at, :duration, :status, :consultation_type, :payment_status, :price_cents, :reason, :notes, :cancellation_reason, :cancelled_at, :created_at, :updated_at

  attribute :price do |appointment|
    appointment.price_cents / 100
  end

  attribute :ends_at do |appointment|
    appointment.ends_at.iso8601
  end

  attribute :cancellable do |appointment|
    appointment.cancellable?
  end

  association :practitioner_profile, key: :practitioner, transform: PractitionerProfileSerializer
  association :patient_profile, key: :patient, transform: PatientProfileSerializer

  association :cancelled_by_user, key: :cancelled_by, transform: UserSerializer, if: proc { |appointment| appointment.cancelled_by_user.present? }
end