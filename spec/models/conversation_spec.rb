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

    it 'validates uniqueness of patient_profile_id scoped to practitioner_profile_id' do
      existing = create(:conversation_with_appointment)
      duplicate = build(:conversation_with_appointment,
        patient_profile: existing.patient_profile,
        practitioner_profile: existing.practitioner_profile
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:patient_profile_id]).to be_present
    end

    context 'patient_must_have_appointment_with_practitioner' do
      it 'is invalid if patient has no appointment with practitioner' do
        patient_profile = create(:patient_profile)
        practitioner_profile = create(:practitioner_profile)

        conversation = build(:conversation,
          patient_profile: patient_profile,
          practitioner_profile: practitioner_profile
        )

        expect(conversation).not_to be_valid
        expect(conversation.errors[:base]).to include(match(/rendez-vous/i))
      end

      it 'is valid if patient has at least one appointment with practitioner' do
        appointment = create(:appointment)

        conversation = build(:conversation, :with_appointment,
          patient_profile: appointment.patient_profile,
          practitioner_profile: appointment.practitioner_profile
        )

        expect(conversation).to be_valid
      end
    end

    context 'must be initiated by patient' do
      it 'is valid if is initiated by patient' do
        appointment = create(:appointment)
        conversation = build(
          :conversation,
          patient_profile: appointment.patient_profile,
          practitioner_profile: appointment.practitioner_profile,
          initiated_by: :patient
        )

        expect(conversation).to be_valid
      end

      it 'is valid if initiated by is not define' do
        appointment = create(:appointment)
        conversation = build(
          :conversation,
          patient_profile: appointment.patient_profile,
          practitioner_profile: appointment.practitioner_profile
        )

        expect(conversation).to be_valid
      end

      it 'is invalid if intiated_by practitioner' do
        appointment = create(:appointment)
        conversation = build(
          :conversation,
          patient_profile: appointment.patient_profile,
          practitioner_profile: appointment.practitioner_profile,
          initiated_by: :practitioner
        )

        expect(conversation).not_to be_valid
        expect(conversation.errors[:base]).to include("Seul un patient peut initier une conversation")
      end
    end
  end

  describe '.for_user' do
    it 'returns conversations for a patient user' do
      appointment = create(:appointment)
      conversation = create(:conversation, :with_appointment,
        patient_profile: appointment.patient_profile,
        practitioner_profile: appointment.practitioner_profile
      )

      other_conversation = create(:conversation_with_appointment)

      result = Conversation.for_user(appointment.patient_profile.user)

      expect(result).to include(conversation)
      expect(result).not_to include(other_conversation)
    end

    it 'returns conversations for a practitioner user' do
      appointment = create(:appointment)
      conversation = create(:conversation, :with_appointment,
        patient_profile: appointment.patient_profile,
        practitioner_profile: appointment.practitioner_profile
      )

      other_conversation = create(:conversation_with_appointment)

      result = Conversation.for_user(appointment.practitioner_profile.user)

      expect(result).to include(conversation)
      expect(result).not_to include(other_conversation)
    end
  end
end
