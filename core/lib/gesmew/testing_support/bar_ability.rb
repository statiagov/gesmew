# Fake ability for testing administration
class BarAbility
  include CanCan::Ability

  def initialize(user)
    user ||= Gesmew::User.new
    if user.has_gesmew_role? 'bar'
      # allow dispatch to :admin, :index, and :show on Gesmew::Order
      can [:admin, :index, :show], Gesmew::Order
      # allow dispatch to :index, :show, :create and :update shipments on the admin
      can [:admin, :manage], Gesmew::Shipment
    end
  end
end
