require 'spec_helper'
require 'cancan/matchers'
require 'gesmew/testing_support/ability_helpers'
require 'gesmew/testing_support/bar_ability'

# Fake ability for testing registration of additional abilities
class FooAbility
  include CanCan::Ability

  def initialize(user)
    # allow anyone to perform index on Inspection
    can :index, Gesmew::Inspection
    # allow anyone to update an Inspection with id of 1
    can :update, Gesmew::Inspection do |inspection|
      inspection.id == 1
    end
  end
end

describe Gesmew::Ability, :type => :model do
  let(:user) { create(:user) }
  let(:ability) { Gesmew::Ability.new(user) }
  let(:token) { nil }

  before do
    user.gesmew_roles.clear
  end

  TOKEN = 'token123'

  after(:each) {
    Gesmew::Ability.abilities = Set.new
    user.gesmew_roles = []
  }

  context 'register_ability' do
    it 'should add the ability to the list of abilties' do
      Gesmew::Ability.register_ability(FooAbility)
      expect(Gesmew::Ability.new(user).abilities).not_to be_empty
    end

    it 'should apply the registered abilities permissions' do
      Gesmew::Ability.register_ability(FooAbility)
      expect(Gesmew::Ability.new(user).can?(:update, mock_model(Gesmew::Inspection, :id => 1))).to be true
    end
  end

  context 'for general resource' do
    let(:resource) { Object.new }

    context 'with admin user' do
      before(:each) { allow(user).to receive(:has_gesmew_role?).and_return(true) }
      it_should_behave_like 'access granted'
      it_should_behave_like 'index allowed'
    end

    context 'with customer' do
      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
    end
  end
end
