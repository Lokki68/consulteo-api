class PatientProfile < ApplicationRecord
  belongs_to :user

  has_many :appointments, dependent: :destroy
  has_many :consultations, through: :appointments
  has_many :conversations, dependent: :destroy

  encrypts :social_security_number
  blind_index :social_security_number

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
