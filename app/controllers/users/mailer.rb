class Users::Mailer < Devise::Mailer
  default from: "from@example.com"

  def registration_confirmation(resource)
    @resource = resource
    mail to: resource.email, subject: "ユーザー登録完了のお知らせ"
  end
end
