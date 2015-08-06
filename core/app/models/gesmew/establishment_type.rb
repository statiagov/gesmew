module Gesmew
  class EstablishmentType < Gesmew::Base

    has_many :establishments

    validates_uniqueness_of :name
    validates_presence_of   :name
  end
end
