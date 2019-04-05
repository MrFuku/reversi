FactoryBot.define do
  factory :user, aliases: [:owner, :guest] do
    name "user-name"
    sequence(:email) { |n| "test#{n}@test.com"}
    password "password"
  end
end
