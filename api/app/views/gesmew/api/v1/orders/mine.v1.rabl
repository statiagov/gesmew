object false

child(@orders => :orders) do
  extends "gesmew/api/v1/orders/show"
end

node(:count) { @orders.count }
node(:current_page) { params[:page] || 1 }
node(:pages) { @orders.num_pages }
