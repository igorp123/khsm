require 'rails_helper'

RSpec.feature 'USER looks an alien profile', type: :feature do

  let(:users) { [FactoryBot.create(:user), FactoryBot.create(:user, name: 'Vasya')] }

  let!(:games) do
    [
      FactoryBot.create(:game, user: users.last, id: 2,
                        current_level: 2, created_at: Time.parse('2018.01.10'), prize: 10000),
      FactoryBot.create(:game, user: users.last, id: 747,
                        current_level: 5, created_at: Time.parse('2018.01.20, 22:00'),
                        finished_at: Time.parse('2018.01.20, 22:20'), is_failed: false,
                        prize: 100000)
    ]
  end

  before(:each) do
    login_as users.first
  end

  scenario 'successfully' do
    visit '/'
    click_link 'Vasya'

    expect(page).to have_current_path '/users/2'

    expect(page).to have_content 'Vasya'

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
