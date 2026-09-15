class Availability < ApplicationRecord
  belongs_to :practitioner_profile

  enum :day_of_week, {
    monday: 0, tuesday: 1, wednesday: 2, thursday: 3,
    friday: 4, saturday: 5, sunday: 6
  }

  validates :day_of_week, presence: true
  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_availability

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "doit etre après start_time") if end_time <= start_time
  end

  def no_overlapping_availability
    return if practitioner_profile.id.blank? || day_of_week.blank?
    overlapping = practitioner_profile.availability
      .where(day_of_week: day_of_week)
      .where.not(id: id)
      .where("start_time < ? AND end_time > ?", end_time, start_time)

    errors.add(:base, "Ce créneau chevauche une disponibilité existante") if overlapping.exists?
  end
end
