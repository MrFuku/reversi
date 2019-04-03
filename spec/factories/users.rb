FactoryBot.define do
  factory :user, aliases: [:owner, :guest] do
    sequence(:email) { |n| "test#{n}@test.com"}
    password "password"
  end
end
