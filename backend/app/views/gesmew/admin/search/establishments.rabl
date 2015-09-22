collection(@establishments)
attributes :name, :id
node(:owner_name) do |e|
  e.contact_information.fullname
end
