require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  before { signin_as admin }

  describe 'GET index' do
    it 'renders the dashboard index' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'contains pending confirm orders' do
      3.times { FactoryGirl.create(:payment_order, success: true) }
      get :index
      expect(assigns(:pd_confirm_orders).count).to eq(3)
    end

    it 'contains pending shipment orders' do
      2.times { FactoryGirl.create(:service_order) }
      get :index
      expect(assigns(:pd_shipment_orders).count).to eq(2)
    end

    it 'contains pending pickup confirmation orders' do
      FactoryGirl.create(:service_order, pickup_pending: true)
      get :index
      expect(assigns(:pd_pickup_orders).count).to eq(1)
    end

    it 'contains pending delivery confirmation orders' do
      4.times { FactoryGirl.create(:service_order, shipped: true) }
      get :index
      expect(assigns(:pd_delivery_orders).count).to eq(4)
    end

    it 'contains pending withdraw transfers' do
      2.times { FactoryGirl.create(:bank_transfer, status: 1) }
      3.times { FactoryGirl.create(:alipay_transfer, status: 1) }
      get :index
      expect(assigns(:pd_withdraws).count).to eq(5)
    end

    context 'access control' do
      it 'does not allow non-admin access' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
