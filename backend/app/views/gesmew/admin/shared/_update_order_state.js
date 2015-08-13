$('#order_tab_summary h5#order_status').html('<%= j Gesmew.t(:status) %>: <%= j Gesmew.t(@inspection.state, :scope => :order_state) %>');
$('#order_tab_summary h5#order_total').html('<%= j Gesmew.t(:total) %>: <%= j @inspection.display_total.to_html %>');

<% if @inspection.completed? %>
  $('#order_tab_summary h5#payment_status').html('<%= j Gesmew.t(:payment) %>: <%= j Gesmew.t(@inspection.payment_state, :scope => :payment_states, :default => [:missing, "none"]) %>');
  $('#order_tab_summary h5#shipment_status').html('<%= j Gesmew.t(:shipment) %>: <%= j Gesmew.t(@inspection.shipment_state, :scope => :shipment_state, :default => [:missing, "none"]) %>');
<% end %>
