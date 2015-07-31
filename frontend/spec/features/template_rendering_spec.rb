require 'spec_helper'

describe "Template rendering", type: :feature do

  after do
    Capybara.ignore_hidden_elements = true
  end

  before do
    Capybara.ignore_hidden_elements = false
  end

  it 'layout should have canonical tag referencing site url' do
    Gesmew::Store.create!(code: 'gesmew', name: 'My Gesmew Store', url: 'gesmewstore.example.com', mail_from_address: 'test@example.com')

    visit gesmew.root_path
    expect(find('link[rel=canonical]')[:href]).to eql('http://gesmewstore.example.com/')
  end
end
