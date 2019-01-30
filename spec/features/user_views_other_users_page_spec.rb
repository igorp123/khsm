require 'rails_helper'

RSpec.feature 'USER views an other users page', type: :feature do

  let!(:vasya) { FactoryBot.create(:user, name: 'Vasya') }

  let(:petya) { FactoryBot.create(:user, name: 'Petya') }


  let!(:games) do
    [
      FactoryBot.create(:game, user: petya, id: 2,
                        current_level: 2, created_at: Time.parse('2018.01.10'), prize: 10000),
      FactoryBot.create(:game, user: petya, id: 747,
                        current_level: 5, created_at: Time.parse('2018.01.20, 22:00'),
                        finished_at: Time.parse('2018.01.20, 22:20'), is_failed: false,
                        prize: 100000)
    ]
  end

  before(:each) do
    login_as vasya
  end

  scenario 'successfully' do
    visit '/'

    click_link 'Petya'

    expect(page).to have_current_path '/users/2'

    expect(page).to have_content 'Petya'

    expect(page).to have_content 'деньги'
    expect(page).to have_content 'в процессе'
    expect(page).to have_content '20 янв., 22:00'
    expect(page).to have_content '10 янв., 00:00'
    expect(page).to have_content '100 000 ₽'
    expect(page).to have_content '10 000 ₽'
    expect(page).to have_content '747'

    expect(page).not_to have_content 'Сменить имя и пароль'
  end
end
