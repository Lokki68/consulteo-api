class AvailabilityException < ApplicationRecord
  belongs_to :practitioner_profile

  enum :exception_type, { closed: 0, open: 1 }

  validates :date, presence: true

  validate :times_presence_if_open
  validate :end_after_start_if_present

  scope :for_date, ->(date) { where(date: date) }

  private

  def times_presence_if_open
    return unless open?

    errors.add(:start_time, "requis pour une ouverture exceptionnelle") if start_time.blank?
    errors.add(:end_time, "requis pour une ouverture exceptionnelle.") if end_time.blank?
  end

  def end_after_start_if_present
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "doit être après l'heure de début") if end_time <= start_time
  end
end
