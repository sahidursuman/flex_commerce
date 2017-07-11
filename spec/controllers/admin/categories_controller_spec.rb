require 'rails_helper'

RSpec.describe Admin::CategoriesController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }
  let(:category) { FactoryGirl.create(:category) }

  before { signin_as(admin) }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to render_template(:index)
    end

    context 'access control' do
      it 'does not allow non-admin access' do
        signin_as(customer)
        get :index
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET new' do
    it 'responses successfully' do
      get :new
      expect(response).to render_template(:new)
      expect(assigns(:category)).to be_a_new(Category)
    end
  end

  describe 'POST create' do
    describe 'category creation' do
      context 'with valid params' do
        it 'creates category' do
          post :create, params: { category: { name: 'Drama',
                                              display_order: 0 } }
          expect(response).to redirect_to(admin_categories_path)
          expect(flash[:success]).to be_present
        end
      end

      context 'with invalid params' do
        it 'does not create and renders new action' do
          post :create, params: { category: { parent_id: 9999,
                                              name: 'Invalid Cat'},
                                              display_order: 0 }
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET edit' do
    it 'responses successfully' do
      get :edit, params: { id: category.id }
      expect(response).to render_template(:edit)
      expect(assigns(:category)).to be_an_instance_of(Category)
    end
  end

  describe 'PATCH update' do
    before do
      category = FactoryGirl.create(:category)
    end

    it 'updates with valid params' do
      patch :update, params: { id: category.id,
                               category: { name: 'New Name',
                                           display_order: 10 } }
      expect(category.reload.name).to eq('New Name')
      expect(category.reload.display_order).to eq(10)
      expect(response).to redirect_to(admin_categories_path)
      expect(flash[:success]).to be_present
    end

    it 'rejects update action when given invalid params' do
      patch :update, params: { id: category.id,
                               category: { parent_id: 9999999} }
      expect(response).to render_template(:edit)
    end
  end

end
