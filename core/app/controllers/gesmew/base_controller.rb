require 'cancan'
require_dependency 'gesmew/core/controller_helpers/strong_parameters'

class Gesmew::BaseController < ApplicationController
  include Gesmew::Core::ControllerHelpers::Auth
  include Gesmew::Core::ControllerHelpers::RespondWith
  include Gesmew::Core::ControllerHelpers::Common
  include Gesmew::Core::ControllerHelpers::StrongParameters

  def unauthorized
    render 'gesmew/shared/unauthorized', layout: Gesmew::Config[:layout], status: 401
  end

  respond_to :html
end

require 'gesmew/i18n/initializer'
