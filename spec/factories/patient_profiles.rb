FactoryBot.define do
  factory :patient_profile do
    association :user, :patient

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    to_create do |instance|
      instance.user.patient_profile.update!(
        first_name: first_name,
        last_name: last_name,
      )
    end

    initialize_with do
      user.patient_profile || new
    end
  end
end
