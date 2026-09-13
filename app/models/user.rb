require "devise"
require "devise/jwt"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self


  enum :role, { patient: 0, practitioner: 1, admin: 2 }

  has_one :patient_profile, dependent: :destroy
  has_one :practitioner_profile, dependent: :destroy

  validates :role, presence: true

  before_create { self.jti = SecureRandom.uuid }
  after_create :create_associated_profile

  private

  def create_associated_profile
    case role
    when "patient"
      create_patient_profile!
    when "practitioner"
      create_practitioner_profile!
    end
  end
end
