module Gesmew
  module TestingSupport
    module AuthorizationHelpers
      module CustomAbility
        def build_ability(&block)
          block ||= proc{ |u| can :manage, :all }
          Class.new do
            include CanCan::Ability
            define_method(:initialize, block)
          end
        end
      end

      module Controller
        include CustomAbility

        def stub_authorization!(&block)
          ability_class = build_ability(&block)
          before do
            allow(controller).to receive(:current_ability).and_return(ability_class.new(nil))
          end
        end
      end

      module Request
        include CustomAbility

        def stub_authorization!
          ability = build_ability

          after(:all) do
            Gesmew::Ability.remove_ability(ability)
          end

          before(:all) do
            Gesmew::Ability.register_ability(ability)
          end

          before do
            allow(Gesmew.user_class).to receive(:find_by).
                                         with(hash_including(:gesmew_api_key)).
                                         and_return(Gesmew.user_class.new)
          end
        end

        def custom_authorization!(&block)
          ability = build_ability(&block)
          after(:all) do
            Gesmew::Ability.remove_ability(ability)
          end
          before(:all) do
            Gesmew::Ability.register_ability(ability)
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.extend Gesmew::TestingSupport::AuthorizationHelpers::Controller, type: :controller
  config.extend Gesmew::TestingSupport::AuthorizationHelpers::Request, type: :feature
end
