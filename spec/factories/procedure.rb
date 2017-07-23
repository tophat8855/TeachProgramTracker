FactoryGirl.define do
  factory :procedure do
    resident_name { Faker::Name.name }
    date { Date.today - 7.days }
    name { 'IUD' }
    assistance { 'Observed' }
    resident_status { 'R2' }
    user_id { 2 }
    trainer_id { 1000 }
    trainer_name { 'Factory Trainer' }
    clinic_location { 'Oakland' }
    notes { Faker::Lorem.sentence }
  end
end
