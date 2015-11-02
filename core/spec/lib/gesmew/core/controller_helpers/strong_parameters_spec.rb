require 'spec_helper'

class FakesController < ApplicationController
  include Gesmew::Core::ControllerHelpers::StrongParameters
end

describe Gesmew::Core::ControllerHelpers::StrongParameters, type: :controller do
  controller(FakesController) {}

  describe '#permitted_attributes' do
    it 'returns Gesmew::PermittedAttributes module' do
      expect(controller.permitted_attributes).to eq Gesmew::PermittedAttributes
    end
  end
end
