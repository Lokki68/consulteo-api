require "devise"
require "devise/jwt"

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self


  enum :role, { patient: 0, practitioner: 1, admin: 2 }

  has_one :patient_profile, dependent: :destroy
  has_one :practitioner_profile, dependent: :destroy

  validates :role, presence: true

  before_create { self.jti = SecureRandom.uuid }
  after_create :create_associated_profile

  def profile_completed?
    profile = patient_profile || practitioner_profile
    return false unless profile

    profile.first_name.present? && profile.last_name.present?
  end

  def go_online!
    update_column(:online, true)
  end

  def go_offline!
    update_column(:online, false)
  end

  def full_name
    profile = patient_profile || practitioner_profile
    return "" unless profile

    "#{profile.first_name} #{profile.last_name}".strip
  end

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
