10.times do |n|
  email = "user#{n}@user.com"
  password = "password"
  User.create!(email: email,
               password:              password,
               password_confirmation: password)
end
