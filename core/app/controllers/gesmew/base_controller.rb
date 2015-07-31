require 'cancan'
require_dependency 'gesmew/core/controller_helpers/strong_parameters'

class Gesmew::BaseController < ApplicationController
  include Gesmew::Core::ControllerHelpers::Auth
  include Gesmew::Core::ControllerHelpers::RespondWith
  include Gesmew::Core::ControllerHelpers::Common
  include Gesmew::Core::ControllerHelpers::Search
  include Gesmew::Core::ControllerHelpers::StrongParameters

  respond_to :html
end

require 'gesmew/i18n/initializer'
