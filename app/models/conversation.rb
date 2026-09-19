# app/models/conversation.rb
class Conversation < ApplicationRecord
  belongs_to :patient_profile
  belongs_to :practitioner_profile

  has_many :messages, dependent: :destroy

  validates :patient_profile_id, uniqueness: { scope: :practitioner_profile_id }
  validate :patient_must_have_appointment_with_practitioner, on: :create

  scope :for_user, ->(user) {
    if user.patient?
      joins(:patient_profile).where(patient_profiles: { user_id: user.id })
    else
      joins(:practitioner_profile).where(practitioner_profiles: { user_id: user.id })
    end
  }

  def other_participant(current_user)
    current_user == patient_profile.user ? practitioner_profile.user : patient_profile.user
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  private

  def patient_must_have_appointment_with_practitioner
    return if patient_profile_id.blank? || practitioner_profile_id.blank?

    has_appointment = Appointment.exists?(
      patient_profile_id: patient_profile_id,
      practitioner_profile_id: practitioner_profile_id
    )

    unless has_appointment
      errors.add(:base, "Une conversation nécessite au moins un rendez-vous préalable avec ce praticien")
    end
  end
end