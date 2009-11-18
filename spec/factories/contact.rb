Factory.define :contact do |c|
  c.first_name 'Ryan'
  c.last_name 'Neufeld'
end

Factory.define :full_contact, :class => Contact do |c|

  c.first_name 'Bryan'
end
