require 'rails_helper'

RSpec.describe AvailabilityException, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:date) }

    it 'est valide avec des attributs par défaut de la factory' do
      exception = build(:availability_exception)
      expect(exception).to be_valid
    end

    it 'est invalide ouvert sans start_time' do
      execption = build(:availability_exception, :open, start_time: nil)
      expect(execption).not_to be_valid
      expect(execption.errors[:start_time]).to be_present
    end

    it 'est invalide ouvert sans end_time' do
      expection = build(:availability_exception, :open, end_time: nil)
      expect(expection).not_to be_valid
      expect(expection.errors[:end_time]).to be_present
    end

    it 'est valide ouvert avec horaires cohérentes' do
      expection = build(:availability_exception, :open)
      expect(expection).to be_valid
    end

    it 'est invalide si end_time est avant start_time' do
      exception = build(:availability_exception, :open, start_time: "12:00", end_time: "10:00")
      expect(exception).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:practitioner_profile) }
  end

  describe '.for_date' do
    it 'retourne les exceptions pour une date donnée' do
      practitioner = create(:practitioner_profile)
      matching = create(:availability_exception, date: Date.new(2026, 9, 14), practitioner_profile: practitioner)
      other = create(:availability_exception, date: Date.new(2026, 9, 20), practitioner_profile: practitioner)

      expect(AvailabilityException.for_date(Date.new(2026, 9, 14))).to include(matching)
      expect(AvailabilityException.for_date(Date.new(2026, 9, 14))).not_to include(other)
    end
  end
end
