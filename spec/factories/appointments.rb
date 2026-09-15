FactoryBot.define do
  factory :appointment do
    association :practitioner_profile
    association :patient_profile
    starts_at { Time.zone.parse('2026-09-14 09:00') }
    ends_at { Time.zone.parse('2026-09-14 09:30') }
    status { :confirmed }
  end
end
