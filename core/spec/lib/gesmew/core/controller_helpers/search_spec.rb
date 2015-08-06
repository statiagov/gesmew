# require 'spec_helper'
#
# class FakesController < ApplicationController
#   include Gesmew::Core::ControllerHelpers::Search
# end
#
# describe Gesmew::Core::ControllerHelpers::Search, type: :controller do
#   controller(FakesController) {}
#
#   describe '#build_searcher' do
#     it 'returns Gesmew::Core::Search::Base instance' do
#       allow(controller).to receive_messages(try_gesmew_current_user: create(:user),
#                       current_currency: 'USD')
#       expect(controller.build_searcher({}).class).to eq Gesmew::Core::Search::Base
#     end
#   end
# end
