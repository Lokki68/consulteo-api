FactoryBot.define do
  factory :appointment do
    association :practitioner_profile
    association :patient_profile

    scheduled_at { 1.day.from_now.change(hour: 10, min: 0) }
    duration { 30 }
    status { :pending }
    reason { 'Consultation de routine' }

    trait :cancelled do
      status { :cancelled }
      cancellation_reason { 'Empechement patient' }
    end

    trait :confirmed do
      status { :confirmed }
    end
  end
end
