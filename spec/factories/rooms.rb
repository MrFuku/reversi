FactoryBot.define do
  factory :room do
    association :owner
    association :guest
  end
end
