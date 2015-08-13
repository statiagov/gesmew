module Gesmew
  module ProductsHelper
    # returns the formatted price for the specified variant as a full price or a difference depending on configuration
    def variant_price(variant)
      if Gesmew::Config[:show_variant_full_price]
        variant_full_price(variant)
      else
        variant_price_diff(variant)
      end
    end

    # returns the formatted price for the specified variant as a difference from establishment price
    def variant_price_diff(variant)
      variant_amount = variant.amount_in(current_currency)
      product_amount = variant.establishment.amount_in(current_currency)
      return if variant_amount == product_amount || product_amount.nil?
      diff   = variant.amount_in(current_currency) - product_amount
      amount = Gesmew::Money.new(diff.abs, currency: current_currency).to_html
      label  = diff > 0 ? :add : :subtract
      "(#{Gesmew.t(label)}: #{amount})".html_safe
    end

    # returns the formatted full price for the variant, if at least one variant price differs from establishment price
    def variant_full_price(variant)
      establishment = variant.establishment
      unless establishment.variants.active(current_currency).all? { |v| v.price == establishment.price }
        Gesmew::Money.new(variant.price, { currency: current_currency }).to_html
      end
    end

    # converts line breaks in establishment description into <p> tags (for html display purposes)
    def product_description(establishment)
      if Gesmew::Config[:show_raw_product_description]
        raw(establishment.description)
      else
        raw(establishment.description.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>'))
      end
    end

    def line_item_description(variant)
      ActiveSupport::Deprecation.warn "line_item_description(variant) is deprecated and may be removed from future releases, use line_item_description_text(line_item.description) instead.", caller

      line_item_description_text(variant.establishment.description)
    end

    def line_item_description_text description_text
      if description_text.present?
        truncate(strip_tags(description_text.gsub('&nbsp;', ' ').squish), length: 100)
      else
        Gesmew.t(:product_has_no_description)
      end
    end

    def cache_key_for_products
      count = @establishments.count
      max_updated_at = (@establishments.maximum(:updated_at) || Date.today).to_s(:number)
      products_cache_keys = "gesmew/establishments/all-#{params[:page]}-#{max_updated_at}-#{count}"
      (common_product_cache_keys + [products_cache_keys]).compact.join("/")
    end

    def cache_key_for_product(establishment = @establishment)
      (common_product_cache_keys + [establishment.cache_key, establishment.possible_promotions]).compact.join("/")
    end

    private

    def common_product_cache_keys
      [I18n.locale, current_currency, current_tax_zone.try(:cache_key)]
    end
  end
end
