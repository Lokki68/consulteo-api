class Appointment < ApplicationRecord
  belongs_to :practitioner_profile
  belongs_to :patient_profile

  has_one :consultation, dependent: :destroy

  enum :status, {
    pending: 0,
    confirmed: 1,
    cancelled: 2,
    completed: 3,
    no_show: 4
  }

  validates :scheduled_at, presence: true
  validates :duration, presence: true
  validate :no_overlap_for_practitioner, on: :create

  scope :active, -> { where.not(status: :cancelled) }
  scope :on_date, ->(date) { where(scheduled_at: date.beginning_of_day..date.end_of_day) }

  def ends_at
    scheduled_at + duration_minutes.minutes
  end

  private

  def no_overlap_for_practitioner
    return if scheduled_at.blank?

    overlapping = practitioner_profile.appointments
                                      .active
                                      .where.not(id: id)
                                      .where("scheduled_at < ? AND (scheduled_at + (duration || 'minutes')::interval)  > ?", ends_at, scheduled_at)

    errors.add(:base, "Ce créneau chevauche un rendez-vous existant") if overlapping.exists?
  end
end
