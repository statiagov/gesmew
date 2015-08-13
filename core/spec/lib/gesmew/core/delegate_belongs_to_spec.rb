require 'spec_helper'

# This is a bit of a insane spec I have to admit
# Chosed the gesmew_payment_methods table because it has a `name` column
# already. Stubs wouldn't work here (the delegation runs before this spec is
# loaded) and adding a column here might make the test even crazy so here we go
module Gesmew
  class DelegateBelongsToStubModel < Gesmew::Base
    self.table_name = "gesmew_establishment_types"
    belongs_to :contact_information
    delegate_belongs_to :contact_informationt, :firstname
  end

  describe DelegateBelongsToStubModel do
    context "model has column attr delegated to associated object" do
      it "doesnt touch the associated object" do
        expect(subject).not_to receive(:establishment)
        subject.name
      end
    end
  end
end
