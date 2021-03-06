require 'rails_helper'

RSpec.describe Customer, type: :model do

  let(:customer)        { FactoryBot.create(:customer) }
  let(:completed_order) { FactoryBot.create(:service_order, completed: true) }

  describe 'creation' do
    it 'can be created' do
      expect(customer).to be_valid
      expect(customer.type).to eq('Customer')
    end
  end

  describe '#customer?' do
    it 'returns true when user is an admin' do
      expect(customer.customer?).to be_truthy
    end
  end
end
