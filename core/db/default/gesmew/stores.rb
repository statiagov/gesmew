# Possibly already created by a migration.
unless Gesmew::Store.where(code: 'gesmew').exists?
  Gesmew::Store.new do |s|
    s.code              = 'gesmew'
    s.name              = 'Gesmew Demo Site'
    s.url               = 'example.com'
    s.mail_from_address = 'gesmew@example.com'
  end.save!
end
