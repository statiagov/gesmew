require 'spec_helper'

describe Gesmew::Admin::RefundsController do
  stub_authorization!

  describe "POST create" do
    context "a Gesmew::Core::GatewayError is raised" do

      let(:payment) { create(:payment) }

      subject do
        gesmew_post :create,
                   refund: { amount: "50.0", refund_reason_id: "1" },
                   order_id: payment.order.to_param,
                   payment_id: payment.to_param
      end

      before(:each) do
        def controller.create
          raise Gesmew::Core::GatewayError.new('An error has occurred')
        end
      end

      it "sets an error message with the correct text" do
        subject
        expect(flash[:error]).to eq 'An error has occurred'
      end

      it { should render_template(:new) }
    end
  end
end
