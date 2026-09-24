# app/models/conversation.rb
class Conversation < ApplicationRecord
  include Stateful

  attr_accessor :initiated_by

  belongs_to :patient_profile
  belongs_to :practitioner_profile

  has_many :messages, dependent: :destroy

  validates :patient_profile_id, uniqueness: { scope: :practitioner_profile_id }
  validate :patient_must_have_appointment_with_practitioner, on: :create
  validate :initiator_must_be_patient, on: :create

  scope :for_user, ->(user) {
    if user.patient?
      joins(:patient_profile).where(patient_profiles: { user_id: user.id })
    else
      joins(:practitioner_profile).where(practitioner_profiles: { user_id: user.id })
    end
  }

  define_state_machine do
    state :active, initial: true
    state :archived
    state :closed

    event :archive do
      transitions from: :active, to: :archived
    end

    event :reopen do
      transitions from: [:archived, :closed], to: :active
    end

    event :close do
      transitions from: :active, to: :closed
    end
  end

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

  def initiator_must_be_patient
    return if initiated_by.nil?

    errors.add(:base, "Seul un patient peut initier une conversation") unless initiated_by.to_sym == :patient
  end
end