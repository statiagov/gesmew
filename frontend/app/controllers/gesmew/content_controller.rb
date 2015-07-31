module Gesmew
  class ContentController < Gesmew::StoreController
    # Don't serve local files or static assets
    before_filter { render_404 if params[:path] =~ /(\.|\\)/ }
    after_action :fire_visited_path, only: :show

    rescue_from ActionView::MissingTemplate, :with => :render_404

    respond_to :html

    def show
      render :action => params[:path]
    end

    def cvv
      render :layout => false
    end

    def fire_visited_path
      Gesmew::PromotionHandler::Page.new(current_order, params[:path]).activate
    end
  end
end
