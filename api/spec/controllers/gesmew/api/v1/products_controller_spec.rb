require 'spec_helper'
require 'shared_examples/protect_product_actions'

module Gesmew
  describe Api::V1::ProductsController, :type => :controller do
    render_views

    let!(:establishment) { create(:establishment) }
    let!(:inactive_product) { create(:establishment, available_on: Time.now.tomorrow, name: "inactive") }
    let(:base_attributes) { Api::ApiHelpers.product_attributes }
    let(:show_attributes) { base_attributes.dup.push(:has_variants) }
    let(:new_attributes) { base_attributes }

    let(:product_data) do
      { name: "The Other Establishment",
        price: 19.99,
        shipping_category_id: create(:shipping_category).id }
    end
    let(:attributes_for_variant) do
      h = attributes_for(:variant).except(:option_values, :establishment)
      h.merge({
        options: [
          { name: "size", value: "small" },
          { name: "color", value: "black" }
        ]
      })
    end

    before do
      stub_authentication!
    end

    context "as a normal user" do
      context "with caching enabled" do
        let!(:product_2) { create(:establishment) }

        before do
          ActionController::Base.perform_caching = true
        end

        it "returns unique establishments" do
          api_get :index
          product_ids = json_response["establishments"].map { |p| p["id"] }
          expect(product_ids.uniq.count).to eq(product_ids.count)
        end

        after do
          ActionController::Base.perform_caching = false
        end
      end

      it "retrieves a list of establishments" do
        api_get :index
        expect(json_response["establishments"].first).to have_attributes(show_attributes)
        expect(json_response["total_count"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["per_page"]).to eq(Kaminari.config.default_per_page)
      end

      it "retrieves a list of establishments by id" do
        api_get :index, :ids => [establishment.id]
        expect(json_response["establishments"].first).to have_attributes(show_attributes)
        expect(json_response["total_count"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["per_page"]).to eq(Kaminari.config.default_per_page)
      end

      context "establishment has more than one price" do
        before { establishment.master.prices.create currency: "EUR", amount: 22 }

        it "returns distinct establishments only" do
          api_get :index
          expect(assigns(:establishments).map(&:id).uniq).to eq assigns(:establishments).map(&:id)
        end
      end

      it "retrieves a list of establishments by ids string" do
        second_product = create(:establishment)
        api_get :index, :ids => [establishment.id, second_product.id].join(",")
        expect(json_response["establishments"].first).to have_attributes(show_attributes)
        expect(json_response["establishments"][1]).to have_attributes(show_attributes)
        expect(json_response["total_count"]).to eq(2)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["per_page"]).to eq(Kaminari.config.default_per_page)
      end

      it "does not return inactive establishments when queried by ids" do
        api_get :index, :ids => [inactive_product.id]
        expect(json_response["count"]).to eq(0)
      end

      it "does not list unavailable establishments" do
        api_get :index
        expect(json_response["establishments"].first["name"]).not_to eq("inactive")
      end

      context "pagination" do
        it "can select the next page of establishments" do
          second_product = create(:establishment)
          api_get :index, :page => 2, :per_page => 1
          expect(json_response["establishments"].first).to have_attributes(show_attributes)
          expect(json_response["total_count"]).to eq(2)
          expect(json_response["current_page"]).to eq(2)
          expect(json_response["pages"]).to eq(2)
        end

        it 'can control the page size through a parameter' do
          create(:establishment)
          api_get :index, :per_page => 1
          expect(json_response['count']).to eq(1)
          expect(json_response['total_count']).to eq(2)
          expect(json_response['current_page']).to eq(1)
          expect(json_response['pages']).to eq(2)
        end
      end

      it "can search for establishments" do
        create(:establishment, :name => "The best establishment in the world")
        api_get :index, :q => { :name_cont => "best" }
        expect(json_response["establishments"].first).to have_attributes(show_attributes)
        expect(json_response["count"]).to eq(1)
      end

      it "gets a single establishment" do
        establishment.master.images.create!(:attachment => image("thinking-cat.jpg"))
        establishment.variants.create!
        establishment.variants.first.images.create!(:attachment => image("thinking-cat.jpg"))
        establishment.set_property("gesmew", "rocks")
        establishment.taxons << create(:taxon)

        api_get :show, :id => establishment.to_param

        expect(json_response).to have_attributes(show_attributes)
        expect(json_response['variants'].first).to have_attributes([:name,
                                                              :is_master,
                                                              :price,
                                                              :images,
                                                              :in_stock])

        expect(json_response['variants'].first['images'].first).to have_attributes([:attachment_file_name,
                                                                                :attachment_width,
                                                                                :attachment_height,
                                                                                :attachment_content_type,
                                                                                :mini_url,
                                                                                :small_url,
                                                                                :product_url,
                                                                                :large_url])

        expect(json_response["product_properties"].first).to have_attributes([:value,
                                                                         :product_id,
                                                                         :property_name])

        expect(json_response["classifications"].first).to have_attributes([:taxon_id, :position, :taxon])
        expect(json_response["classifications"].first['taxon']).to have_attributes([:id, :name, :pretty_name, :permalink, :taxonomy_id, :parent_id])
      end

      context "tracking is disabled" do
        before { Config.track_inventory_levels = false }

        it "still displays valid json with total_on_hand Float::INFINITY" do
          api_get :show, :id => establishment.to_param
          expect(response).to be_ok
          expect(json_response[:total_on_hand]).to eq nil
        end

        after { Config.track_inventory_levels = true }
      end

      context "finds a establishment by slug first then by id" do
        let!(:other_product) { create(:establishment, :slug => "these-are-not-the-droids-you-are-looking-for") }

        before do
          establishment.update_column(:slug, "#{other_product.id}-and-1-ways")
        end

        specify do
          api_get :show, :id => establishment.to_param
          expect(json_response["slug"]).to match(/and-1-ways/)
          establishment.destroy

          api_get :show, :id => other_product.id
          expect(json_response["slug"]).to match(/droids/)
        end
      end

      it "cannot see inactive establishments" do
        api_get :show, :id => inactive_product.to_param
        assert_not_found!
      end

      it "returns a 404 error when it cannot find a establishment" do
        api_get :show, :id => "non-existant"
        assert_not_found!
      end

      it "can learn how to create a new establishment" do
        api_get :new
        expect(json_response["attributes"]).to eq(new_attributes.map(&:to_s))
        required_attributes = json_response["required_attributes"]
        expect(required_attributes).to include("name")
        expect(required_attributes).to include("price")
        expect(required_attributes).to include("shipping_category_id")
      end

      it_behaves_like "modifying establishment actions are restricted"
    end

    context "as an admin" do
      let(:taxon_1) { create(:taxon) }
      let(:taxon_2) { create(:taxon) }

      sign_in_as_admin!

      it "can see all establishments" do
        api_get :index
        expect(json_response["establishments"].count).to eq(2)
        expect(json_response["count"]).to eq(2)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["pages"]).to eq(1)
      end

      # Regression test for #1626
      context "deleted establishments" do
        before do
          create(:establishment, :deleted_at => 1.day.ago)
        end

        it "does not include deleted establishments" do
          api_get :index
          expect(json_response["establishments"].count).to eq(2)
        end

        it "can include deleted establishments" do
          api_get :index, :show_deleted => 1
          expect(json_response["establishments"].count).to eq(3)
        end
      end

      describe "creating a establishment" do
        it "can create a new establishment" do
          api_post :create, :establishment => { :name => "The Other Establishment",
                                          :price => 19.99,
                                          :shipping_category_id => create(:shipping_category).id }
          expect(json_response).to have_attributes(base_attributes)
          expect(response.status).to eq(201)
        end

        it "creates with embedded variants" do
          product_data.merge!({
            variants: [attributes_for_variant, attributes_for_variant]
          })

          api_post :create, :establishment => product_data
          expect(response.status).to eq 201

          variants = json_response['variants']
          expect(variants.count).to eq(2)
          expect(variants.last['option_values'][0]['name']).to eq('small')
          expect(variants.last['option_values'][0]['option_type_name']).to eq('size')

          expect(json_response['option_types'].count).to eq(2) # size, color
        end

        it "can create a new establishment with embedded product_properties" do
          product_data.merge!({
            product_properties_attributes: [{
              property_name: "fabric",
              value: "cotton"
            }]
          })

          api_post :create, :establishment => product_data

          expect(json_response['product_properties'][0]['property_name']).to eq('fabric')
          expect(json_response['product_properties'][0]['value']).to eq('cotton')
        end

        it "can create a new establishment with option_types" do
          product_data.merge!({
            option_types: ['size', 'color']
          })

          api_post :create, :establishment => product_data
          expect(json_response['option_types'].count).to eq(2)
        end

        it "creates establishment with option_types ids" do
          option_type = create(:option_type)
          product_data.merge!(option_type_ids: [option_type.id])
          api_post :create, establishment: product_data
          expect(json_response['option_types'].first['id']).to eq option_type.id
        end

        it "creates with shipping categories" do
          hash = { :name => "The Other Establishment",
                   :price => 19.99,
                   :shipping_category => "Free Ships" }

          api_post :create, :establishment => hash
          expect(response.status).to eq 201

          shipping_id = ShippingCategory.find_by_name("Free Ships").id
          expect(json_response['shipping_category_id']).to eq shipping_id
        end

        it "puts the created establishment in the given taxons" do
          product_data[:taxon_ids] = [taxon_1.id, taxon_2.id]
          api_post :create, establishment: product_data
          expect(json_response["taxon_ids"]).to eq([taxon_1.id, taxon_2.id])
        end

        # Regression test for #2140
        context "with authentication_required set to false" do
          before do
            Gesmew::Api::Config.requires_authentication = false
          end

          after do
            Gesmew::Api::Config.requires_authentication = true
          end

          it "can still create a establishment" do
            api_post :create, :establishment => product_data, :token => "fake"
            expect(json_response).to have_attributes(show_attributes)
            expect(response.status).to eq(201)
          end
        end

        it "cannot create a new establishment with invalid attributes" do
          api_post :create, establishment: {}
          expect(response.status).to eq(422)
          expect(json_response["error"]).to eq("Invalid resource. Please fix errors and try again.")
          errors = json_response["errors"]
          errors.delete("slug") # Don't care about this one.
          expect(errors.keys).to match_array(["name", "price", "shipping_category_id"])
        end
      end

      context 'updating a establishment' do
        it "can update a establishment" do
          api_put :update, :id => establishment.to_param, :establishment => { :name => "New and Improved Establishment!" }
          expect(response.status).to eq(200)
        end

        it "can create new option types on a establishment" do
          api_put :update, :id => establishment.to_param, :establishment => { :option_types => ['shape', 'color'] }
          expect(json_response['option_types'].count).to eq(2)
        end

        it "can create new variants on a establishment" do
          api_put :update, :id => establishment.to_param, :establishment => { :variants => [attributes_for_variant, attributes_for_variant.merge(sku: "ABC-#{Kernel.rand(9999)}")] }
          expect(response.status).to eq 200
          expect(json_response['variants'].count).to eq(2) # 2 variants

          variants = json_response['variants'].select { |v| !v['is_master'] }
          expect(variants.last['option_values'][0]['name']).to eq('small')
          expect(variants.last['option_values'][0]['option_type_name']).to eq('size')

          expect(json_response['option_types'].count).to eq(2) # size, color
        end

        it "can update an existing variant on a establishment" do
          variant_hash = {
            :sku => '123', :price => 19.99, :options => [{:name => "size", :value => "small"}]
          }
          variant_id = establishment.variants.create!({ establishment: establishment }.merge(variant_hash)).id

          api_put :update, :id => establishment.to_param, :establishment => {
            :variants => [
              variant_hash.merge(
                :id => variant_id.to_s,
                :sku => '456',
                :options => [{:name => "size", :value => "large" }]
              )
            ]
          }

          expect(json_response['variants'].count).to eq(1)
          variants = json_response['variants'].select { |v| !v['is_master'] }
          expect(variants.last['option_values'][0]['name']).to eq('large')
          expect(variants.last['sku']).to eq('456')
          expect(variants.count).to eq(1)
        end

        it "cannot update a establishment with an invalid attribute" do
          api_put :update, :id => establishment.to_param, :establishment => { :name => "" }
          expect(response.status).to eq(422)
          expect(json_response["error"]).to eq("Invalid resource. Please fix errors and try again.")
          expect(json_response["errors"]["name"]).to eq(["can't be blank"])
        end

        it "puts the updated establishment in the given taxons" do
          api_put :update, id: establishment.to_param, establishment: { taxon_ids: [taxon_1.id, taxon_2.id] }
          expect(json_response["taxon_ids"].to_set).to eql([taxon_1.id, taxon_2.id].to_set)
        end
      end

      it "can delete a establishment" do
        expect(establishment.deleted_at).to be_nil
        api_delete :destroy, :id => establishment.to_param
        expect(response.status).to eq(204)
        expect(establishment.reload.deleted_at).not_to be_nil
      end
    end
  end
end
