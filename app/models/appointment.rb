class Appointment < ApplicationRecord
  include Stateful

  belongs_to :practitioner_profile
  belongs_to :patient_profile
  belongs_to :cancelled_by_user, class_name: 'User', optional: true

  has_one :consultation, dependent: :destroy

  enum :consultation_type, { in_person: 0, video: 1, phone: 2 }

  enum :payment_status, { unpaid: 0, paid: 1, refunded: 2, partially_paid: 3 }

  validates :scheduled_at, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :no_overlap_for_practitioner, on: :create
  validate :no_overlap_for_practitioner, if: :scheduled_at_changed?, on: :update

  scope :active, -> { where.not(status: :cancelled) }
  scope :on_date, ->(date) { where(scheduled_at: date.beginning_of_day..date.end_of_day) }
  scope :upcoming, -> { where('scheduled_at > ?', Time.current).active }
  scope :past, -> { where('scheduled_at < ?', Time.current).active }
  scope :for_patient, ->(patient_profile_id) { where(patient_profile_id: patient_profile_id) }
  scope :for_practitioner, ->(practitioner_profile_id) { where(practitioner_profile_id: practitioner_profile_id) }

  define_state_machine do
    state :pending, initial: true
    state :confirmed
    state :cancelled
    state :completed
    state :no_show

    event :confirm do
      transitions from: :pending, to: :confirmed
    end

    event :cancel do
      transitions from: [:pending, :confirmed], to: :cancelled
    end

    event :complete do
      transitions from: :confirmed, to: :completed
    end

    event :mark_no_show do
      transitions from: :confirmed, to: :no_show
    end
  end

  def ends_at
    scheduled_at + duration.minutes
  end

  def price
    price_cents / 100.0
  end

  def self.between?(patient_profile_id, practitioner_profile_id)
    exists?(patient_profile_id, practitioner_profile_id)
  end

  def cancellable?
    return false if cancelled? || completed? || no_show?

    deadline_hours = practitioner_profile.cancellation_deadline_hours
    scheduled_at > Time.current + deadline_hours
  end

  def cancel_with_reason!(by:, reason:)
    raise Appointment::NotCancellableError unless cancellable?

    cancel!

    update!(
      cancelled_by_user: by,
      cancelled_at: Time.current,
      cancellation_reason: reason,
    )
  end

  def reschedule!(new_scheduled_at:, reason:)
    raise Appointment::NotCancellableError unless cancellable?

    update!(
      scheduled_at: new_scheduled_at,
      rescheduled_reason: reason,
      status: :pending
    )
  end

  class NotCancellableError < StandardError; end

  private

  def no_overlap_for_practitioner
    return if scheduled_at.blank?

    overlapping = practitioner_profile.appointments
                                      .active
                                      .where.not(id: id)
                                      .where("scheduled_at < ? AND (scheduled_at + (duration || ' minutes')::interval)  > ?", ends_at, scheduled_at)

    errors.add(:base, "Ce créneau chevauche un rendez-vous existant") if overlapping.exists?
  end
end
