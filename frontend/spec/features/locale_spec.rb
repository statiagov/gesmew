require 'spec_helper'

describe 'setting locale', type: :feature do
  def with_locale(locale)
    I18n.locale = locale
    Gesmew::Frontend::Config[:locale] = locale
    yield
    I18n.locale = 'en'
    Gesmew::Frontend::Config[:locale] = 'en'
  end

  context 'shopping cart link and page' do
    before do
      I18n.backend.store_translations(:fr,
       gesmew: {
         cart: 'Panier',
         shopping_cart: 'Panier'
      })
    end

    it 'should be in french' do
      with_locale('fr') do
        visit gesmew.root_path
        click_link 'Panier'
        expect(page).to have_content('Panier')
      end
    end
  end

  context 'checkout form validation messages' do
    include_context 'checkout setup'

    let(:error_messages) do
      {
        'en' => 'This field is required.',
        'fr' => 'Ce champ est obligatoire.',
        'de' => 'Dieses Feld ist ein Pflichtfeld.',
      }
    end

    def check_error_text(text)
      %w(firstname lastname address1 city).each do |attr|
        expect(find("#b#{attr} label.error").text).to eq(text)
      end
    end

    it 'shows translated jquery.validate error messages', js: true do
      visit gesmew.root_path
      click_link mug.name
      click_button 'add-to-cart-button'
      error_messages.each do |locale, message|
        with_locale(locale) do
          visit '/checkout/address'
          find('.form-buttons input[type=submit]').click
          check_error_text message
        end
      end
    end
  end
end
