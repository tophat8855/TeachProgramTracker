FactoryGirl.define do
  factory :residency_location do
    name { Faker::Address.city }
  end
end
