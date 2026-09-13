class Speciality < ApplicationRecord
  has_and_belongs_to_many :practitioner_profiles

  validates :name, :slug, presence: :true, uniqueness: true
      t.timestamps
end
