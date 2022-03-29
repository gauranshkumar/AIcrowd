FactoryBot.define do
  factory :blitz_subscription do
    participant_id { 1 }
    start_date { "2022-03-29 10:54:08" }
    end_date { "2022-03-29 10:54:08" }
    source { "MyString" }
  end
end
