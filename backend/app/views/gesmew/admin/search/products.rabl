object false
node(:count) { @establishments.count }
node(:total_count) { @establishments.total_count }
node(:current_page) { params[:page] ? params[:page].to_i : 1 }
node(:per_page) { params[:per_page] || Kaminari.config.default_per_page }
node(:pages) { @establishments.num_pages }
child(@establishments => :establishments) do
  attributes :id, :name
end
