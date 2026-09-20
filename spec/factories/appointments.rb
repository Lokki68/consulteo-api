FactoryBot.define do
  factory :appointment do
    association :practitioner_profile
    association :patient_profile

    sequence(:scheduled_at) { |n| (Date.tomorrow + n.days).change(hour: 10) }
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
