require 'rails_helper'

RSpec.describe Product, type: :model do

  let(:product) { FactoryGirl.create(:product) }

  describe 'creation' do
    it 'can be created' do
      expect(product).to be_valid
    end
  end

  describe 'validation' do
    it 'requires product to have a name' do
      no_name = FactoryGirl.build(:product, name: nil)
      no_name.valid?
      expect(no_name.errors.messages[:name]).to be_present
    end

    it 'requires product name to be shorter than 31 characters' do
      long_name = FactoryGirl.build(:product, name: "#{'x' * 31}")
      long_name.valid?
      expect(long_name.errors.messages[:name]).to be_present
    end

    it 'requires product to have a positive value' do
      neg_price_market = FactoryGirl.build(:product, price_market_cents: -100)
      neg_price_market.valid?
      expect(neg_price_market.errors.messages[:price_market]).to be_present
    end
  end

  describe '#extract_images' do
    intro = '<a href=\"/uploads/store/a1350f1dca616cc4f8dca4f46c136c54.jpeg\"'
    desc = 't;/uploads/store/a1350f1dca616cc4f8dca4f46c136c54.jpgpe=\"image/jpeg\"'
    spec = '<img src=\"/uploads/store/123.png\"> <img src=\"/uploads/store/789.png\">'

    let(:prod_image_1) { FactoryGirl.create(:product, description: desc) }
    let(:prod_image_3) { FactoryGirl.create(:product, introduction: intro,
                                                      description: desc,
                                                      specification: spec) }

    it 'populations an array of image file name' do
      expect(prod_image_1.send(:extract_images).count).to eq(1)
      expect(prod_image_3.send(:extract_images).count).to eq(4)
    end

    it 'returns an empty array if no images are found' do
      expect(product.send(:extract_images)).to eq([])
    end
  end

  describe '#result_cleanup' do
    it 'removes empty and flatten arrays' do
      result = product.send(:result_cleanup, [["abcd.jpg", "123.png"], [], []])
      expect(result).to eq(["abcd.jpg", "123.png"])
    end

    it 'removes extra slash in filename' do
      result = product.send(:result_cleanup, ['/123.png', "/abc.jpeg"])
      expect(result).to eq(['123.png', 'abc.jpeg'])
    end
  end

  context 'image association' do
    before do
      @img_1 = FactoryGirl.create(:image)
      @img_2 = FactoryGirl.create(:image)
      @unrelated_img_3 = FactoryGirl.create(:image)
      desc = "/" + @img_1.image[:fit].data['id']
      spec = "/" + @img_2.image[:fit].data['id']
      @product = FactoryGirl.create(:product, description: desc,
                                              specification: spec)
    end

    describe '#associate_images' do
      it 'associates images with product' do
        @product.associate_images
        expect(@product.images).to match_array([@img_1, @img_2])
      end

      it 'logs the source channel as editor' do
        @product.associate_images
        expect(@product.images.first.source_channel).to eq('editor')
      end

      it 'does not associate unrelated images' do
        @product.associate_images
        expect(@product.images).not_to include(@unrelated_img_3)
      end
    end

    describe '#unassociate_images' do
      it 'unassociate products images' do
        @product.associate_images
        @product.unassociate_images
        expect(@product.reload.images).to be_empty
      end
    end
  end
end
