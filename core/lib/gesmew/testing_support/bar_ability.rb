# Fake ability for testing administration
class BarAbility
  include CanCan::Ability

  def initialize(user)
    user ||= Gesmew::User.new
    if user.has_gesmew_role? 'bar'
      # allow dispatch to :admin, :index, and :show on Gesmew::Inspection
      can [:admin, :index, :show], Gesmew::Inspection
      # allow dispatch to :index, :show, :create and :update shipments on the admin
      can [:admin, :manage], Gesmew::Establishment
    end
  end
end
