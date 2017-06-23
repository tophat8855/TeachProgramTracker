FactoryGirl.define do
  factory :procedure do
    resident_name { Faker::Name.name }
    date { Date.today - 7.days }
    name { 'IUD' }
    assistance { 'Observed' }
    residentstatus { 'R2' }
    user_id { 2 }
    trainer_id { 1 }
    clinic_location { 'Oakland' }
  end
end
