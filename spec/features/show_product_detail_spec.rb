require 'rails_helper'

describe 'product detail', type: :feature do
  before do
    create_placeholder_image
    @cat = FactoryBot.create(:category)
    @brand = FactoryBot.create(:brand)
    @product_1 = FactoryBot.create(:product, price_market: 100.01, price_member: 99.02)
    Categorization.create(category: @cat, product: @product_1)
    Categorization.create(category: @brand, product: @product_1)
  end

  it 'shows product detail information' do
    visit product_path(@product_1)

    expect(page).to have_content(@product_1.name)
    expect(page).to have_content(@product_1.tag_line)
    expect(page).to have_content(@product_1.sku)
    expect(page).to have_content(@product_1.categories.brand.first.name)
    expect(page).to have_content(@product_1.introduction)
    expect(page).to have_content(@product_1.price_market)
    expect(page).to have_content(@product_1.price_member)
    expect(page).to have_content(@product_1.description)
    expect(page).to have_content(@product_1.specification)
  end
end
