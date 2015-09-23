collection(@users)
attributes :email, :id
node(:name) do |u|
  u.fullname
end
child(:gesmew_roles => :roles) {
  attributes :name
}
