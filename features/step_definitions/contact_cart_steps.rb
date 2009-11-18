Given /I am logged in/ do
  basic_auth('ryan','cohort')
end

When /I check the contact with name "(.*)"/ do |name|
  check field(name)
end
