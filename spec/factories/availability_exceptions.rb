FactoryBot.define do
  factory :availability_exception do
    association :practioner_profile
    date { Date.new(2026, 9, 14) }
    exception_type { :closed }
    start_time { nil }
    end_time { nil }
  end
end
