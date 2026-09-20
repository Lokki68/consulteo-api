FactoryBot.define do
  factory :message do
    conversation
    sender factory: :user

    content { 'Bonjour, ceci est un message' }
  end
end
