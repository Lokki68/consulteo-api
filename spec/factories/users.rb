FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    role { :patient }

    trait :practitioner do
      role { :practitioner }
    end

    trait :patient do
      role { :patient }
    end
  end
end
