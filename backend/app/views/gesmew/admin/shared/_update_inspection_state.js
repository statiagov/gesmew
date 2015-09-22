$('#order_tab_summary h5#order_status').html('<%= j Gesmew.t(:status) %>: <%= j Gesmew.t(@inspection.state, :scope => :inspection_state) %>');
