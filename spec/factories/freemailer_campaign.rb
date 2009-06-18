Factory.define :freemailer_campaign do |f|
  f.subject "You've been pre-approved to lower you're interest rate"
  f.title "Spam Email"
  f.body_template "Hi <name>,\n You've been pre-approved!"
  f.association :sender, :factory => :user
end
