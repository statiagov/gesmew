node do |t|
  child t.children => :taxons do
    attributes *taxon_attributes

    extends "gesmew/api/v1/taxons/taxons"
  end
end
