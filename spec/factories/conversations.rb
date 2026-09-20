FactoryBot.define do
  factory :conversation do
    patient_profile
    practitioner_profile

    trait :with_appointment do
      after(:build) do |conversation|
        create(:appointment,
               patient_profile: conversation.patient_profile,
               practitioner_profile: conversation.practitioner_profile
        )
      end
    end
  end

  factory :conversation_with_appointment, parent: :conversation, traits: [ :with_appointment ]
end
