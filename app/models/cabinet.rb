class Cabinet < ApplicationRecord
  has_many :practitioner_profiles, dependent: :nullify

  validates :name, presence: true
end
