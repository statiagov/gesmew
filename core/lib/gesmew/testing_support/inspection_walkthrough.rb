class InspectionWalkthrough
  def self.up_to(state)

    inspection = Gesmew::Inspection.create!(email: "gesmew@example.com")
    add_line_item!(inspection)
    inspection.next!

    end_state_position = states.index(state.to_sym)
    states[0...end_state_position].each do |state|
      send(state, inspection)
    end

    inspection
  end

  private

  def self.contact_info(inspection)
    inspection.next!
  end

  def self.delivery(inspection)
    inspection.next!
  end

  def self.complete(inspection)
    #noop?
  end

  def self.states
    [:address, :delivery, :payment, :complete]
  end

end
