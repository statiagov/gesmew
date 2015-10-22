# Gesmew::Sample.load_sample("establishment")
#
# inspections = []
# inspections << Gesmew::Inspection.create!(
#   :number => "N123456789",
#   :establishment => Gesmew::Establishment.first
#   )
#
# inspections.each(&:create_proposed_shipments)
#
# inspections.each do |inspection|
#   inspection.state = "complete"
#   inspection.completed_at = Time.now - 1.day
#   inspection.save!
# end
