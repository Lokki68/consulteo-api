require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:sender).class_name('User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'broadcasting' do
    it 'broadcast the message after creation' do
      conversation = create(:conversation_with_appointment)

      expect(ConversationChannel).to receive(:broadcast_to).with(conversation, hash_including(type: 'message'))

      create(:message, conversation: conversation, sender: conversation.patient_profile.user)
    end
  end
end
