require 'rails_helper'

RSpec.describe Admin::InventoriesController, type: :controller do

  let(:admin)     { FactoryBot.create(:admin) }
  let(:inventory) { FactoryBot.create(:inventory) }
  let(:product)   { FactoryBot.create(:product) }

  before { signin_as admin }

  describe 'GET index' do

    before do
      @unsold =       FactoryBot.create(:inventory)
      @in_cart =      FactoryBot.create(:inventory, status: 1)
      @in_order =     FactoryBot.create(:inventory, status: 2)
      @in_checkout =  FactoryBot.create(:inventory, status: 3)
      @sold =         FactoryBot.create(:inventory, status: 4)
      @returned =     FactoryBot.create(:inventory, status: 5)
    end

    it 'response successfully' do
      get :index
      expect(response).to render_template(:index)
      expect(response).to be_success
    end

    it 'returns all inventories' do
      get :index
      expect(assigns(:inventories).count).to eq(6)
    end

    it 'returns all unsold inventories' do
      get :index, params: { status: 'unsold' }
      expect(assigns(:inventories)).to match_array([@unsold])
    end

    it 'returns all in cart inventories' do
      get :index, params: { status: 'in_cart' }
      expect(assigns(:inventories)).to match_array([@in_cart])
    end

    it 'returns all in order inventories' do
      get :index, params: { status: 'in_order' }
      expect(assigns(:inventories)).to match_array([@in_order])
    end

    it 'returns all in checkout inventories' do
      get :index, params: { status: 'in_checkout' }
      expect(assigns(:inventories)).to match_array([@in_checkout])
    end

    it 'returns all sold inventories' do
      get :index, params: { status: 'sold' }
      expect(assigns(:inventories)).to match_array([@sold])
    end

    it 'returns all returned inventories' do
      get :index, params: { status: 'returned' }
      expect(assigns(:inventories)).to match_array([@returned])
    end

    it 'returns all destroyable inventories' do
      get :index, params: { status: 'destroyable' }
      expect(assigns(:inventories)).to match_array([@unsold, @in_cart, @in_order])
    end

    it 'returns all undestroyable inventories' do
      get :index, params: { status: 'undestroyable' }
      expect(assigns(:inventories)).to match_array([@in_checkout, @sold, @returned])
    end
  end

  describe 'GET show' do
    it 'returns a success response' do
      get :show, params: { id: inventory.id }
      expect(response).to be_success
      expect(assigns(:inventory)).to eq(inventory)
    end
  end

  describe 'DELETE destroy' do
    it 'can be destroy if its status is destroyable' do
      unsold = FactoryBot.create(:inventory)
      expect {
        delete :destroy, params: { id: unsold.id }
      }.to change(Inventory, :count).by(-1)
      expect(flash[:success]).to be_present
      expect(response).to redirect_to(admin_inventories_path)
    end

    it 'cannot be destroy if its status is undestroyable' do
      in_checkout = FactoryBot.create(:inventory, status: 3)
      expect {
        delete :destroy, params: { id: in_checkout.id }
      }.to change(Inventory, :count).by(0)
      expect(flash[:danger]).to be_present
    end
  end

end
