FactoryBot.define do
  factory :practitioner_profile do
    association :user
    association :cabinet

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    rpps_number { Faker::Number.number(digits: 11).to_s }
  end
end
