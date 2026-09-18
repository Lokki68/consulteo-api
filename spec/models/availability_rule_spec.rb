require 'rails_helper'

RSpec.describe AvailabilityRule, type: :model do
  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:day_of_week).in_range(0..6) }

    it 'est valide avec des attributs par défaut de la factory' do
      rule = build(:availability_rule)
      expect(rule).to be_valid
    end

    it "n'est pas valide si end_time est avant start_time" do
      rule = build(:availability_rule, start_time: "12:00", end_time: "11:00")
      expect(rule).to_not be_valid
      expect(rule.errors[:end_time]).to be_present
    end

    it "n'est pas valide si valid_until est avant valid_from" do
      rule = build(:availability_rule, valid_from: Date.new(2026, 1, 1), valid_until: Date.new(2025, 12, 25))
      expect(rule).to_not be_valid
    end

    it 'est valid sans valid_until (rule permanente)' do
      rule = build(:availability_rule, valid_until: nil)
      expect(rule).to be_valid
    end

  end

  describe 'associations' do
    it { is_expected.to belong_to(:practitioner_profile)}
  end
end
