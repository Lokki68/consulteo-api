FactoryBot.define do
  factory :availability_exception do
    association :practitioner_profile
    date { Date.new(2026, 9, 14) }
    exception_type { :closed }
    start_time { nil }
    end_time { nil }

    trait :open do
      exception_type { :open }
      start_time { "09:00" }
      end_time { "12:00" }
    end
  end
end
