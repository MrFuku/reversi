for n in 1..30 do
  name = "ユーザー#{n}"
  email = "user#{n}@user.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password:              password,
               password_confirmation: password)
  Result.create!(user_id: n)
end

for i in 1..10 do
  for j in 1..10 do
    if i != j
      Friendship.create!(user_id: i, friend_id: j)
    end
  end
end
