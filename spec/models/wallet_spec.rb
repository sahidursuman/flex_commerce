require 'rails_helper'

RSpec.describe Wallet, type: :model do

  let(:customer)         { FactoryGirl.create(:customer) }
  let(:wealthy_customer) { FactoryGirl.create(:wealthy_customer) }

  describe 'creation' do
    it 'can be created with user' do
      expect(customer.wallet).to be_present
    end

    it 'cannot be standalone' do
      expect { Wallet.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'deletion' do
    it 'cannot be deleted from user' do
      expect(customer.wallet.destroy).to be_falsey
    end
  end

  describe '#available_fund' do
    it 'returns the amount of spendable fund in wallet' do
      wealthy_customer.wallet.update(pending: 99900)
      expect(wealthy_customer.wallet.reload.available_fund).to eq(Money.new(9900))
    end

    it 'returns balance if there is not pending fund' do
      expect(wealthy_customer.wallet.reload.available_fund).to eq(Money.new(9999900))
    end
  end

  describe '#sufficient_fund' do
    it 'returns true if wallet have the query amount' do
      result = wealthy_customer.wallet.sufficient_fund?(Money.new(100000))
      expect(result).to be_truthy
    end

    it 'returns false if available fund does not have the query amount' do
      wealthy_customer.wallet.update(pending: 99998)
      result = wealthy_customer.wallet.sufficient_fund?(Money.new(200))
      expect(result).to be_falsey
    end

    it 'returns false if balance smaller than the query amount' do
      expect(customer.wallet.sufficient_fund?(Money.new(1))).to be_falsey
    end
  end
end
