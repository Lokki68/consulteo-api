FactoryBot.define do
  factory :availability_rule do
    association :practitioner_profile
    day_of_week { 1 }
    start_time { "09:00" }
    end_time { "12:00" }
    slot_duration_minutes { 30 }
    valid_from { Date.new(2026, 1, 1) }
    valid_until { nil }
  end
end
