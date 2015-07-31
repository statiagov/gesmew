object @taxonomy

if set = params[:set]
  extends "gesmew/api/v1/taxonomies/#{set}"
else
  attributes *taxonomy_attributes

  child :root => :root do
      attributes *taxon_attributes

    child :children => :taxons do
      attributes *taxon_attributes
    end
  end
end