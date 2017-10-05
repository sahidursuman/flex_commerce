require 'rails_helper'

RSpec.describe Admin::ApplicationConfigurationsController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:app_config) { ApplicationConfiguration.create(name: 'test_config',
                                                     value: 'test_value') }

  before { signin_as admin }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
      expect(response).to render_template(:index)
    end
  end

  describe 'GET edit' do
    it 'responses successfully' do
      get :edit, params: { id: app_config.id }
      expect(response).to be_success
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    it 'updates app config record with valid params' do
      patch :update, params: {
        id: app_config.id,
        application_configuration: { value: 'new_value' }
      }
      expect(response).to redirect_to(admin_application_configurations_path)
      expect(flash[:success]).to be_present
      expect(app_config.reload.value).to eq('new_value')
    end

    it 'renders error messages with invalid params' do
      patch :update, params: {
        id: app_config.id,
        application_configuration: { name: '' }
      }
      expect(response).to render_template(:edit)
    end
  end
end
