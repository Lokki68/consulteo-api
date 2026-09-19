require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:patient_profile) }
    it { is_expected.to belong_to(:practitioner_profile) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
  end

  describe 'validations' do
    it 'validate with valid factory' do
      conversation = build(:conversation)
      expect(conversation).to be_valid
    end

  end
end
