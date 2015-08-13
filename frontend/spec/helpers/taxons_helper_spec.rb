require 'spec_helper'

describe Gesmew::TaxonsHelper, :type => :helper do
  # Regression test for #4382
  it "#taxon_preview" do
    taxon = create(:taxon)
    child_taxon = create(:taxon, parent: taxon)
    product_1 = create(:establishment)
    product_2 = create(:establishment)
    product_3 = create(:establishment)
    taxon.establishments << product_1
    taxon.establishments << product_2
    child_taxon.establishments << product_3

    expect(taxon_preview(taxon.reload)).to eql([product_1, product_2, product_3])
  end
end
