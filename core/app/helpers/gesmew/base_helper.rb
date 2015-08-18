module Gesmew
  module BaseHelper

    def display_price(product_or_variant)
      product_or_variant.
        price_in(current_currency).
        display_price_including_vat_for(current_tax_zone).
        to_html
    end

    def link_to_tracking(shipment, options = {})
      return unless shipment.tracking && shipment.shipping_method

      if shipment.tracking_url
        link_to(shipment.tracking, shipment.tracking_url, options)
      else
        content_tag(:span, shipment.tracking)
      end
    end

    def logo(image_path=Gesmew::Config[:logo])
      link_to image_tag(image_path), gesmew.root_path
    end

    def meta_data
      object = instance_variable_get('@'+controller_name.singularize)
      meta = {}

      if object.kind_of? ActiveRecord::Base
        meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
        meta[:description] = object.meta_description if object[:meta_description].present?
      end
      meta
    end

    def meta_data_tags
      meta_data.map do |name, content|
        tag('meta', name: name, content: content)
      end.join("\n")
    end

    def labelize(str)
      str.delete('.').downcase.tr(" ","_")
    end

    def method_missing(method_name, *args, &block)
      if image_style = image_style_from_method_name(method_name)
        define_image_method(image_style)
        self.send(method_name, *args)
      else
        super
      end
    end

    def pretty_time(time)
      [I18n.l(time.to_date, format: :long), time.strftime("%l:%M %p")].join(" ")
    end

    def seo_url(taxon)
      return gesmew.nested_taxons_path(taxon.permalink)
    end

    # human readable list of variant options
    def variant_options(v, options={})
      v.options_text
    end

    private

    def create_product_image_tag(image, establishment, options, style)
      options.reverse_merge! alt: image.alt.blank? ? establishment.name : image.alt
      image_tag image.attachment.url(style), options
    end

    def define_image_method(style)
      self.class.send :define_method, "#{style}_image" do |establishment, *options|
        options = options.first || {}
        options[:alt] ||= establishment.name
        if establishment.images.empty?
          if !establishment.is_a?(Gesmew::Variant) && !establishment.variant_images.empty?
            create_product_image_tag(establishment.variant_images.first, establishment, options, style)
          else
            if establishment.is_a?(Variant) && !establishment.establishment.variant_images.empty?
              create_product_image_tag(establishment.establishment.variant_images.first, establishment, options, style)
            else
              image_tag "noimage/#{style}.png", options
            end
          end
        else
          create_product_image_tag(establishment.images.first, establishment, options, style)
        end
      end
    end

    # Returns style of image or nil
    def image_style_from_method_name(method_name)
      if method_name.to_s.match(/_image$/) && style = method_name.to_s.sub(/_image$/, '')
        possible_styles = Gesmew::Image.attachment_definitions[:attachment][:styles]
        style if style.in? possible_styles.with_indifferent_access
      end
    end
  end
end
