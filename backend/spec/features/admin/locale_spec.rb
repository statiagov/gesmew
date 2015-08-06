require 'spec_helper'

describe "setting locale", :type => :feature do
  stub_authorization!

  before do
    I18n.locale = I18n.default_locale
    I18n.backend.store_translations(:fr,
      :date => {
        :month_names => [],
      },
      :gesmew => {
        :admin => {
          :tab => { :inspection => "Ordres" }
        },
        :listing_orders => "Ordres",
      })
    Gesmew::Backend::Config[:locale] = "fr"
  end

  after do
    I18n.locale = I18n.default_locale
    Gesmew::Backend::Config[:locale] = "en"
  end

  it "should be in french" do
    visit gesmew.admin_path
    click_link "Ordres"
    expect(page).to have_content("Ordres")
  end
end
