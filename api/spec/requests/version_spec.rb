require 'spec_helper'

describe "Version", type: :request do
  include Gesmew::Api::TestingSupport::Helpers

  let!(:current_api_user) do
    user = Gesmew.user_class.new(:email => "gesmew@example.com")
    user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
    user.generate_gesmew_api_key!
    user
  end

  before do
    stub_authentication!
  end

  let!(:inspections) { 2.times.map { create :inspection } }

  describe "/api" do
    it "be a redirect" do
      get "/api/inspections"
      expect(response).to have_http_status 301
    end
  end

  describe "/api/v1" do
    it "be successful" do
      get "/api/v1/inspections"
      expect(response).to have_http_status 200
    end
  end
end
