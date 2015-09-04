collection(@users)
attributes :email, :id
node(:name) do |u|
  u.full_name
end
child(:gesmew_roles => :roles) {
  attributes :name
}
