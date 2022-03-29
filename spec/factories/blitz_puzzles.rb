FactoryBot.define do
  factory :blitz_puzzle do
    id { 1 }
    challenge_id { 1 }
    app_link { "MyString" }
    baseline_link { "MyString" }
    difficulty { 1 }
    category { "MyString" }
    free { false }
    trial { false }
  end
end
