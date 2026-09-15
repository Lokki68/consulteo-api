class AvailabilityRule < ApplicationRecord
  belongs_to :practitioner_profile

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :slot_duration_minutes, numericality: { greather_than: 0 }

  validate :end_after_start
  validate :valid_until_after_valid_form

  scope :active, -> { where(active: true) }
  scope :for_day, ->(day) { where(day_of_week: day) }
  scope :covering_date, ->(date) { where("valid_from <= ? AND (valid_until IS NULL OR valid_until >= ?", date, date) }

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "doit être après l'heure de début") if end_time <= start_time
  end

  def valid_until_after_valid_form
    return if valid_until.blank?
    errors.add(:valid_until, "doit être après la date de début") if valid_until < valid_from
  end
end
