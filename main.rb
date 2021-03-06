require 'sinatra'
require 'sinatra/reloader' if development?

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'Sj4R#CnTeUOFGQX%XK'

BLACKJACK = 21
DEALER_STAY = 17
STARTING_CASH = 500

helpers do
  def new_deck
    session[:deck] = [
      2, 3, 4, 5, 6, 7, 8, 9, 10, 'jack', 'queen', 'king', 'ace'].product(
      ['C', 'D', 'H', 'S'])

    session[:deck].shuffle!
  end

  def new_game
    session[:player_turn] = true
    session[:player_hand] = []
    session[:player_cash] = STARTING_CASH
    session[:player_bet] = ''
    session[:dealer_hand] = []

    new_deck

    2.times do
      deal(session[:player_hand])
      deal(session[:dealer_hand])
    end

    redirect '/bet'
  end

  def new_hand
    session[:player_turn] = true
    session[:player_hand] = []
    session[:dealer_hand] = []

    2.times do
      deal(session[:player_hand])
      deal(session[:dealer_hand])
    end

    redirect '/bet'
  end

  def generate_card_image_url(card)
    card_image_name = case card[1]
                      when 'H'
                        "hearts_#{card[0].to_s}.png"
                      when 'D'
                        "diamonds_#{card[0].to_s}.png"
                      when 'C'
                        "clubs_#{card[0].to_s}.png"
                      when 'S'
                        "spades_#{card[0].to_s}.png"
                      end

    card_image_url = "<img src=/images/cards/#{card_image_name} />"
  end
  
  def deal(hand)
    hand << session[:deck].pop
  end

  def calculate_hand_total(hand)
    hand_values = hand.map { |card_value| card_value[0] }

    hand_total = 0

    hand_values.each do |card_value|
      if card_value == 'ace'
        hand_total += 11
      else
        hand_total += card_value.to_i == 0 ? 10 : card_value.to_i
      end
    end

    hand_values.select{ |card_value| card_value == 'ace' }.count.times do
      break if hand_total <= 21
      hand_total -= 10
    end

    hand_total
  end

  def player_hand_total
    calculate_hand_total(session[:player_hand])
  end

  def dealer_hand_total
    calculate_hand_total(session[:dealer_hand])
  end

  def player_has_blackjack?
    player_hand_total == BLACKJACK
  end

  def dealer_has_blackjack?
    dealer_hand_total == BLACKJACK
  end

  def player_has_busted?
    player_hand_total > BLACKJACK
  end

  def dealer_has_busted?
    dealer_hand_total > BLACKJACK
  end

  def random_suit
    suits = ['&clubs;', '&diams;', '&hearts;', '&spades;']
    random_suit = suits.sample
    random_suit
  end

  class String
    def is_integer?
      self.to_i.to_s == self
    end
  end

  def initial_blackjack?
    if player_has_blackjack? || dealer_has_blackjack?

      case
      when player_has_blackjack? && dealer_has_blackjack?
        @push = "<strong>It's a Push!</strong> You and the Dealer both have Blackjack"

      when player_has_blackjack?
        session[:player_cash] += session[:player_bet]
        @win = "<strong>Blackjack!</strong> You win!"

      when dealer_has_blackjack?
        session[:player_cash] -= session[:player_bet]
        @lose = "<strong>Dealer hits Blackjack</strong> You lose."

        if session[:player_cash] == 0
          @game_over = true
          @lose = "<strong>You're Broke</strong>. Game Over!"
        end
      end

      session[:player_turn] = false
    end
  end

  def has_blackjack?
    if player_has_blackjack? || dealer_has_blackjack?

      case
      when player_has_blackjack?
        session[:player_cash] += session[:player_bet]
        @win = "<strong>Blackjack!</strong> You win!"

      when dealer_has_blackjack?
        session[:player_cash] -= session[:player_bet]
        @lose = "<strong>Dealer hits Blackjack</strong> You lose."

        if session[:player_cash] == 0
          @game_over = true
          @lose = "<strong>You're Broke</strong>. Game Over!"
        end
      end

      session[:player_turn] = false
      erb :game, layout: false

    else
      redirect '/busted'
    end
  end

  def is_busted?
    if player_has_busted? || dealer_has_busted?

      case
      when player_has_busted?
        session[:player_cash] -= session[:player_bet]
        @lose = "<strong>You busted!</strong> Dealer wins"

        if session[:player_cash] == 0
          @game_over = true
          @lose = "<strong>You're Broke</strong>. Game Over!"
        end

      when dealer_has_busted?
        session[:player_cash] += session[:player_bet]
        @win = "<strong>Dealer Busts</strong> You win!"
      end

      session[:player_turn] = false
      erb :game, layout: false

    else
      redirect '/hand/over'
    end
  end

  def hand_over?
    if session[:player_turn] == false

      case
      when player_hand_total > dealer_hand_total
        session[:player_cash] += session[:player_bet]
        @win = "<strong>You win</strong> this hand!"

      when player_hand_total < dealer_hand_total
        session[:player_cash] -= session[:player_bet]
        @lose = "<strong>Dealer wins</strong> this hand."

        if session[:player_cash] == 0
          @game_over = true
          @lose = "<strong>You're Broke</strong>. Game Over!"
        end

      when player_hand_total == dealer_hand_total
        @push = "<strong>It's a Push</strong> You and the Dealer have the same score."

      end

      erb :game, layout: false

    else
      erb :game, layout: false
    end
  end
end

get '/' do
  session.clear
  erb :index
end

get '/name' do
  erb :name
end

post '/name' do
  session[:player_name] = params[:player_name]

  if session[:player_name].empty?
    @error = "<strong>Please</strong> enter a name."
    erb :name
  else
    redirect '/new_game'
  end
end

get '/new_game' do
  if session[:player_name]
    new_game
  else
    redirect '/name'
  end
end

get '/bet' do
  erb :bet
end

post '/bet' do
  case
  when params[:player_bet].is_integer?
    session[:player_bet] = params[:player_bet].to_i

    if session[:player_bet] > 0 && session[:player_bet] <= session[:player_cash]
      redirect '/game'

    else
      @error = "<strong>Invalid Amount</strong>"
      erb :bet
    end
  else
    @error = "<strong>Invalid Amount</strong>"
    erb :bet
  end
end

post '/new_hand' do
  new_hand
end

get '/blackjack' do
  has_blackjack?
end

get '/busted' do
  is_busted?
end

get '/hand/over' do
  hand_over?
end

post '/player/hit' do
  deal(session[:player_hand])
  redirect '/blackjack'
end

get '/player/stay' do
  session[:player_turn] = false
  redirect '/dealer/hit'
end

get '/dealer/hit' do
  if dealer_hand_total < DEALER_STAY
    deal(session[:dealer_hand])
    redirect '/dealer/hit'
  else
    redirect '/blackjack'
  end
end

get '/game' do
  if initial_blackjack?
    erb :game
  else
    erb :game
  end
end

get '/about' do
  @game_over = true
  erb :about
end

get '/vegas' do
  @game_over = true
  erb :vegas
end

get '/cat' do
  @game_over = true
  erb :cat
end

