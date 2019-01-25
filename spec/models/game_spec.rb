require 'rails_helper'

# Наш собственный класс с вспомогательными методами
require 'support/my_spec_helper'

# Тестовый сценарий для модели Игры
#
# В идеале — все методы должны быть покрыты тестами, в этом классе содержится
# ключевая логика игры и значит работы сайта.
RSpec.describe Game, type: :model do
  # Пользователь для создания игр
  let(:user) { FactoryBot.create(:user) }

  # Игра с прописанными игровыми вопросами
  let(:game_w_questions) do
    FactoryBot.create(:game_with_questions, user: user)
  end

  let(:current_question) do
    game_w_questions.current_game_question
  end

  # Группа тестов на работу фабрики создания новых игр
  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # Генерим 60 вопросов с 4х запасом по полю level, чтобы проверить работу
      # RANDOM при создании игры.
      generate_questions(60)

      game = nil

      # Создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
      # Проверка: Game.count изменился на 1 (создали в базе 1 игру)
      }.to change(Game, :count).by(1).and(
      # GameQuestion.count +15
        change(GameQuestion, :count).by(15).and(
      # Game.count не должен измениться
        change(Question, :count).by(0)
        )
      )

      # Проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      # Проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  # Тесты на основную игровую логику
  context 'game mechanics' do
    # Правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # Текущий уровень игры и статус
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      # Перешли на след. уровень
      expect(game_w_questions.current_level).to eq(level + 1)

      # Ранее текущий вопрос стал предыдущим
      expect(game_w_questions.current_game_question).not_to eq(q)

      # Игра продолжается
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

#61.3
    it 'take_money! finishes game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be > 0

      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end
  end

#61.4
    context '.status' do
      before(:each) do
        game_w_questions.finished_at = Time.now
        expect(game_w_questions.finished?).to be_truthy
      end

      it ':won' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eq(:won)
      end

      it ':fail' do
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:fail)
      end

      it ':timeout' do
        game_w_questions.created_at = 1.hour.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end

      it ':money' do
        expect(game_w_questions.status).to eq(:money)
      end
    end

#61.6
    context 'game methods' do
      before(:each) do
        game_w_questions.current_level = 10
      end

      describe '#current_game_question' do
        it 'return 10-th question' do
          expect(current_question).to eq(game_w_questions.game_questions[10])
        end
      end

      describe '#previous_level' do
        it 'returns 9-th question' do
          expect(game_w_questions.previous_level).to eq(9)
        end
      end
    end

#61.7
    context '.answer_current_question' do
      it 'any correct answer' do
        l = game_w_questions.current_level

        game_w_questions.answer_current_question!('d')

        expect(game_w_questions.status).to eq(:in_progress)
        expect(game_w_questions.current_level).to eq(l + 1)
        expect(game_w_questions.finished_at).to be_falsy
      end

      it 'any incorect answer' do
        game_w_questions.answer_current_question!('c')

        expect(game_w_questions.status).to eq(:fail)
        expect(game_w_questions.finished_at).to be_truthy
        expect(game_w_questions.prize).to eq(0)
      end

      it 'last correct answer'do
        15.times do
          game_w_questions.answer_current_question!('d')
        end

        expect(game_w_questions.status).to eq(:won)
        expect(game_w_questions.finished_at).to be_truthy
        expect(game_w_questions.prize).to eq(1000000)
      end

      it 'any correct answer after timeout' do
        game_w_questions.created_at = 40.minutes.ago

        game_w_questions.finished_at = Time.now

        game_w_questions.answer_current_question!('d')

        expect(game_w_questions.status).to eq(:timeout)
        expect(game_w_questions.finished_at).to be_truthy
        expect(game_w_questions.prize).to eq(0)
      end
    end
end
