require 'rails_helper'

RSpec.describe 'sessions/new' do

  it 'renders the sign in page with correct dom elements' do
    render
    expect(rendered).to match /Sign In/
    expect(rendered).to have_selector('input[name="session[ident]"]')
    expect(rendered).to have_selector('input[name="session[password]"]')
    expect(rendered).to have_selector('input[name="session[remember_me]"]')
    expect(rendered).to have_selector('input[type="submit"]')
  end
end
