require 'spec_helper'

module Gesmew
  describe Api::V1::ImagesController, :type => :controller do
    render_views

    let!(:establishment) { create(:establishment) }
    let!(:attributes) { [:id, :position, :attachment_content_type,
                         :attachment_file_name, :type, :attachment_updated_at, :attachment_width,
                         :attachment_height, :alt] }

    before do
      stub_authentication!
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can upload a new image for a variant" do
        expect do
          api_post :create,
                   :image => { :attachment => upload_image('thinking-cat.jpg'),
                               :viewable_type => 'Gesmew::Variant',
                               :viewable_id => establishment.master.to_param  },
                   :product_id => establishment.id
          expect(response.status).to eq(201)
          expect(json_response).to have_attributes(attributes)
        end.to change(Image, :count).by(1)
      end

      context "working with an existing image" do
        let!(:product_image) { establishment.master.images.create!(:attachment => image('thinking-cat.jpg')) }

        it "can get a single establishment image" do
          api_get :show, :id => product_image.id, :product_id => establishment.id
          expect(response.status).to eq(200)
          expect(json_response).to have_attributes(attributes)
        end

        it "can get a single variant image" do
          api_get :show, :id => product_image.id, :variant_id => establishment.master.id
          expect(response.status).to eq(200)
          expect(json_response).to have_attributes(attributes)
        end

        it "can get a list of establishment images" do
          api_get :index, :product_id => establishment.id
          expect(response.status).to eq(200)
          expect(json_response).to have_key("images")
          expect(json_response["images"].first).to have_attributes(attributes)
        end

        it "can get a list of variant images" do
          api_get :index, :variant_id => establishment.master.id
          expect(response.status).to eq(200)
          expect(json_response).to have_key("images")
          expect(json_response["images"].first).to have_attributes(attributes)
        end

        it "can update image data" do
          expect(product_image.position).to eq(1)
          api_post :update, :image => { :position => 2 }, :id => product_image.id, :product_id => establishment.id
          expect(response.status).to eq(200)
          expect(json_response).to have_attributes(attributes)
          expect(product_image.reload.position).to eq(2)
        end

        it "can delete an image" do
          api_delete :destroy, :id => product_image.id, :product_id => establishment.id
          expect(response.status).to eq(204)
          expect { product_image.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "as a non-admin" do
      it "cannot create an image" do
        api_post :create, :product_id => establishment.id
        assert_unauthorized!
      end

      it "cannot update an image" do
        api_put :update, :id => 1, :product_id => establishment.id
        assert_not_found!
      end

      it "cannot delete an image" do
        api_delete :destroy, :id => 1, :product_id => establishment.id
        assert_not_found!
      end
    end
  end
end
