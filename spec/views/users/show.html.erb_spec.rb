require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) do
    FactoryBot.build_stubbed(:user, name: 'Вадик')
  end

  before(:each) do
    assign(:user, user)

   render
  end

  it 'renders player names' do
    expect(rendered).to match 'Вадик'
  end

  it 'does not render the password button' do
    expect(rendered).not_to match 'Сменить имя и пароль'
  end

  it 'renders the password button' do
    allow(view).to receive(:current_user).and_return(user)

    render

    expect(rendered).to match 'Сменить имя и пароль'
  end

  it 'renders the game partial' do
    assign(:games, [FactoryBot.build_stubbed(:game)])
    stub_template 'users/_game.html.erb' => 'User game goes here'

    render

    expect(rendered).to match 'User game goes here'

  end
end

