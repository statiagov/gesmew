require 'spec_helper'

describe 'establishments', :type => :feature, :caching => true do
  let!(:establishment) { create(:establishment) }
  let!(:product2) { create(:establishment) }
  let!(:taxonomy) { create(:taxonomy) }
  let!(:taxon) { create(:taxon, :taxonomy => taxonomy) }

  before do
    product2.update_column(:updated_at, 1.day.ago)
    # warm up the cache
    visit gesmew.root_path
    assert_written_to_cache("views/en/USD/gesmew/establishments/all--#{establishment.updated_at.utc.to_s(:number)}")
    assert_written_to_cache("views/en/USD/gesmew/establishments/#{establishment.id}-#{establishment.updated_at.utc.to_s(:number)}")
    assert_written_to_cache("views/en/gesmew/taxonomies/#{taxonomy.id}")
    assert_written_to_cache("views/en/taxons/#{taxon.updated_at.utc.to_i}")

    clear_cache_events
  end

  it "reads from cache upon a second viewing" do
    visit gesmew.root_path
    expect(cache_writes.count).to eq(0)
  end

  it "busts the cache when a establishment is updated" do
    establishment.update_column(:updated_at, 1.day.from_now)
    visit gesmew.root_path
    assert_written_to_cache("views/en/USD/gesmew/establishments/all--#{establishment.updated_at.utc.to_s(:number)}")
    assert_written_to_cache("views/en/USD/gesmew/establishments/#{establishment.id}-#{establishment.updated_at.utc.to_s(:number)}")
    expect(cache_writes.count).to eq(2)
  end

  it "busts the cache when all establishments are deleted" do
    establishment.destroy
    product2.destroy
    visit gesmew.root_path
    assert_written_to_cache("views/en/USD/gesmew/establishments/all--#{Date.today.to_s(:number)}-0")
    expect(cache_writes.count).to eq(1)
  end

  it "busts the cache when the newest establishment is deleted" do
    establishment.destroy
    visit gesmew.root_path
    assert_written_to_cache("views/en/USD/gesmew/establishments/all--#{product2.updated_at.utc.to_s(:number)}")
    expect(cache_writes.count).to eq(1)
  end

  it "busts the cache when an older establishment is deleted" do
    product2.destroy
    visit gesmew.root_path
    assert_written_to_cache("views/en/USD/gesmew/establishments/all--#{establishment.updated_at.utc.to_s(:number)}")
    expect(cache_writes.count).to eq(1)
  end
end
