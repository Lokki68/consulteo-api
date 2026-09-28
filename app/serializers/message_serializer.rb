# app/serializers/message_serializer.rb
class MessageSerializer
  include Alba::Resource

  attributes :id, :content, :conversation_id, :sender_id, :created_at, :read_at

  attribute :read do |message|
    message.read_at.present?
  end
end