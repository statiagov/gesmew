module Gesmew
  class HomeController < Gesmew::StoreController
    helper 'gesmew/products'
    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Gesmew::Taxonomy.includes(root: :children)
    end
  end
end
