require 'spec_helper'
require 'cancan/matchers'
require 'gesmew/testing_support/ability_helpers'
require 'gesmew/testing_support/bar_ability'

# Fake ability for testing registration of additional abilities
class FooAbility
  include CanCan::Ability

  def initialize(user)
    # allow anyone to perform index on Order
    can :index, Gesmew::Order
    # allow anyone to update an Order with id of 1
    can :update, Gesmew::Order do |order|
      order.id == 1
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
      expect(Gesmew::Ability.new(user).can?(:update, mock_model(Gesmew::Order, :id => 1))).to be true
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

  context 'for admin protected resources' do
    let(:resource) { Object.new }
    let(:resource_shipment) { Gesmew::Shipment.new }
    let(:resource_product) { Gesmew::Product.new }
    let(:resource_user) { Gesmew.user_class.new }
    let(:resource_order) { Gesmew::Order.new }
    let(:fakedispatch_user) { Gesmew.user_class.new }
    let(:fakedispatch_ability) { Gesmew::Ability.new(fakedispatch_user) }

    context 'with admin user' do
      it 'should be able to admin' do
        user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'admin')
        expect(ability).to be_able_to :admin, resource
        expect(ability).to be_able_to :index, resource_order
        expect(ability).to be_able_to :show, resource_product
        expect(ability).to be_able_to :create, resource_user
      end
    end

    context 'with fakedispatch user' do
      it 'should be able to admin on the order and shipment pages' do
        user.gesmew_roles << Gesmew::Role.find_or_create_by(name: 'bar')

        Gesmew::Ability.register_ability(BarAbility)

        expect(ability).not_to be_able_to :admin, resource

        expect(ability).to be_able_to :admin, resource_order
        expect(ability).to be_able_to :index, resource_order
        expect(ability).not_to be_able_to :update, resource_order
        # ability.should_not be_able_to :create, resource_order # Fails

        expect(ability).to be_able_to :admin, resource_shipment
        expect(ability).to be_able_to :index, resource_shipment
        expect(ability).to be_able_to :create, resource_shipment

        expect(ability).not_to be_able_to :admin, resource_product
        expect(ability).not_to be_able_to :update, resource_product
        # ability.should_not be_able_to :show, resource_product # Fails

        expect(ability).not_to be_able_to :admin, resource_user
        expect(ability).not_to be_able_to :update, resource_user
        expect(ability).to be_able_to :update, user
        # ability.should_not be_able_to :create, resource_user # Fails
        # It can create new users if is has access to the :admin, User!!

        # TODO change the Ability class so only users and customers get the extra premissions?

        Gesmew::Ability.remove_ability(BarAbility)
      end
    end

    context 'with customer' do
      it 'should not be able to admin' do
        expect(ability).not_to be_able_to :admin, resource
        expect(ability).not_to be_able_to :admin, resource_order
        expect(ability).not_to be_able_to :admin, resource_product
        expect(ability).not_to be_able_to :admin, resource_user
      end
    end
  end

  context 'as Guest User' do

    context 'for Country' do
      let(:resource) { Gesmew::Country.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for OptionType' do
      let(:resource) { Gesmew::OptionType.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for OptionValue' do
      let(:resource) { Gesmew::OptionType.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Order' do
      let(:resource) { Gesmew::Order.new }

      context 'requested by same user' do
        before(:each) { resource.user = user }
        it_should_behave_like 'access granted'
        it_should_behave_like 'no index allowed'
      end

      context 'requested by other user' do
        before(:each) { resource.user = Gesmew.user_class.new }
        it_should_behave_like 'create only'
      end

      context 'requested with proper token' do
        let(:token) { 'TOKEN123' }
        before(:each) { allow(resource).to receive_messages guest_token: 'TOKEN123' }
        it_should_behave_like 'access granted'
        it_should_behave_like 'no index allowed'
      end

      context 'requested with inproper token' do
        let(:token) { 'FAIL' }
        before(:each) { allow(resource).to receive_messages guest_token: 'TOKEN123' }
        it_should_behave_like 'create only'
      end
    end

    context 'for Product' do
      let(:resource) { Gesmew::Product.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for ProductProperty' do
      let(:resource) { Gesmew::Product.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Property' do
      let(:resource) { Gesmew::Product.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for State' do
      let(:resource) { Gesmew::State.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Taxons' do
      let(:resource) { Gesmew::Taxon.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Taxonomy' do
      let(:resource) { Gesmew::Taxonomy.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for User' do
      context 'requested by same user' do
        let(:resource) { user }
        it_should_behave_like 'access granted'
        it_should_behave_like 'no index allowed'
      end
      context 'requested by other user' do
        let(:resource) { Gesmew.user_class.new }
        it_should_behave_like 'create only'
      end
    end

    context 'for Variant' do
      let(:resource) { Gesmew::Variant.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

    context 'for Zone' do
      let(:resource) { Gesmew::Zone.new }
      context 'requested by any user' do
        it_should_behave_like 'read only'
      end
    end

  end

end
