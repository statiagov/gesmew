shared_examples "modifying establishment actions are restricted" do
  it "cannot create a new establishment if not an admin" do
    api_post :create, :establishment => { :name => "Brand new establishment!" }
    assert_unauthorized!
  end

  it "cannot update a establishment" do
    api_put :update, :id => establishment.to_param, :establishment => { :name => "I hacked your store!" }
    assert_unauthorized!
  end

  it "cannot delete a establishment" do
    api_delete :destroy, :id => establishment.to_param
    assert_unauthorized!
  end
end

