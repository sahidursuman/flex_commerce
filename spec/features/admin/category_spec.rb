require 'rails_helper'

describe 'Admin Category Dashboard' do

  let(:admin) { FactoryGirl.create(:admin) }

  before do
    @parent_cat = FactoryGirl.create(:category)
    @child_cat  = FactoryGirl.create(:category, parent: @parent, display_order: 5)
    feature_signin_as(admin)
    visit admin_categories_path
  end

  describe 'create' do
    it 'can create category' do
      click_on('New Category')
      expect(page.current_path).to eq(new_admin_category_path)

      fill_in 'category[name]', with: 'Test Category'
      fill_in 'category[display_order]', with: 0
      click_button 'Create Category'
      expect(page).to have_content('Test Category')
      expect(page).to have_content('0')
    end

    it 'can create child category' do
      click_on("new_child_for_#{@parent_cat.id}")
      expect(page.current_path).to eq(new_admin_category_path)

      fill_in 'category[name]', with: 'Test Child Category'
      fill_in 'category[display_order]', with: 2
      click_button 'Create Category'
      expect(page).to have_content('Test Child Category')
      expect(page).to have_content('2')
      expect(page).to have_content(@parent_cat.name)
      expect(page).to have_content(@parent_cat.id)
    end
  end

  describe 'edit' do
    it 'can edit category' do
      click_on("edit_#{@parent_cat.id}")
      fill_in 'category[name]', with: 'New Name'
      fill_in 'category[display_order]', with: 3
      click_button 'Update Category'
      expect(page).to have_content('New Name')
      expect(page).to have_content('3')
    end

    it 'renders error message when given invalid params' do
      click_on("edit_#{@parent_cat.id}")
      fill_in 'category[parent_id]', with: 123456789
      click_button 'Update Category'
      expect(page).to have_css('#error_messages')
    end
  end

  describe 'move category order' do
    it 'can move parent category' do
      click_link("move_down_#{@parent_cat.id}")
      expect(@parent_cat.reload.display_order).to eq(2)

      click_link("move_up_#{@parent_cat.id}")
      click_link("move_up_#{@parent_cat.id}")
      click_link("move_up_#{@parent_cat.id}")
      expect(@parent_cat.reload.display_order).to eq(0)
    end

    it 'can move child category' do
      click_link("move_up_#{@child_cat.id}")
      expect(@child_cat.reload.display_order).to eq(4)

      click_link("move_down_#{@child_cat.id}")
      expect(@child_cat.reload.display_order).to eq(5)
    end
  end
end

