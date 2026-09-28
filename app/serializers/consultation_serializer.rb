class ConsultationSerializer
  include Alba::Resource

  attributes :id, :notes, :diagnosis, :treatment_plan, :status, :created_at, :updated_at

  association :appointment, key: :appointment, transform: AppointmentSerializer
end