module Gesmew
  class TaxonsController < Gesmew::StoreController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    helper 'gesmew/products'

    respond_to :html

    def show
      @taxon = Taxon.friendly.find(params[:id])
      return unless @taxon

      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Gesmew::Taxonomy.includes(root: :children)
    end

    private

    def accurate_title
      @taxon.try(:seo_title) || super
    end
  end
end
