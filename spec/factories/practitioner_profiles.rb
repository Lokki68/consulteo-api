FactoryBot.define do
  factory :practitioner_profile do
    association :user, :practitioner
    association :cabinet

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    rpps_number { Faker::Number.number(digits: 11).to_s }

    to_create do |instance|
      instance.user.practitioner_profile.update!(
        first_name: instance.first_name,
        last_name: instance.last_name,
        rpps_number: instance.rpps_number,
        cabinet: instance.cabinet,
      )
    end

    initialize_with do
      user.practitioner_profile || new
    end
  end
end
