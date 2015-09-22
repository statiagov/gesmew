require 'spec_helper'

class FakesController < Gesmew::Api::BaseController
end

describe Gesmew::Api::BaseController, :type => :controller do
  render_views
  controller(Gesmew::Api::BaseController) do
    def index
      render :text => { "establishments" => [] }.to_json
    end
  end

  before do
    @routes = ActionDispatch::Routing::RouteSet.new.tap do |r|
      r.draw { get 'index', to: 'gesmew/api/base#index' }
    end
  end

  context "cannot make a request to the API" do
    it "without an API key" do
      api_get :index
      expect(json_response).to eq({ "error" => "You must specify an API key." })
      expect(response.status).to eq(401)
    end

    it "with an invalid API key" do
      request.headers["X-Gesmew-Token"] = "fake_key"
      get :index, {}
      expect(json_response).to eq({ "error" => "Invalid API key (fake_key) specified." })
      expect(response.status).to eq(401)
    end

    it "using an invalid token param" do
      get :index, :token => "fake_key"
      expect(json_response).to eq({ "error" => "Invalid API key (fake_key) specified." })
    end
  end

  it 'handles parameter missing exceptions' do
    expect(subject).to receive(:authenticate_user).and_return(true)
    expect(subject).to receive(:load_user_roles).and_return(true)
    expect(subject).to receive(:index).and_raise(ActionController::ParameterMissing.new('foo'))
    get :index, token: 'exception-message'
    expect(json_response).to eql('exception' => 'param is missing or the value is empty: foo')
  end

  it 'handles record invalid exceptions' do
    expect(subject).to receive(:authenticate_user).and_return(true)
    expect(subject).to receive(:load_user_roles).and_return(true)
    resource = Gesmew::Establishment.new
    resource.valid? # get some errors
    expect(subject).to receive(:index).and_raise(ActiveRecord::RecordInvalid.new(resource))
    get :index, token: 'exception-message'
    expect(json_response).to eql('exception' => "Validation failed: Name can't be blank, Establishment type can't be blank, Contact information can't be blank")
  end
end
