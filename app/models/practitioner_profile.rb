class PractitionerProfile < ApplicationRecord
  belongs_to :user
  # belongs_to :cabinet

  has_many :availability_rules, dependent: :destroy
  has_many :availability_exceptions, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :consultations, through: :appointments
  has_many :conversations, dependent: :destroy

  has_and_belongs_to_many :specialities

  enum :sector, { sector_1: 0, sector_2: 1, non_conventionne: 2 }

  validates :first_name, :last_name, presence: true, on: :profile_completion
  validates :rpps_number, presence: true, on: :profile_completion, if: -> { verified? }

  def full_name
    "Dr. #{first_name} #{last_name}"
  end
end
