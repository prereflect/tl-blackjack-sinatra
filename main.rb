require 'sinatra'
require "sinatra/reloader" if development?

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'Sj4R#CnTeUOFGQX%XK'

BLACKJACK = 21
DEALER_STAY = 17

helpers do
  def new_deck
    session[:deck] = [
      2, 3, 4, 5, 6, 7, 8, 9, 10, 'jack', 'queen', 'king', 'ace'].product(
      ['C', 'D', 'H', 'S'])

    session[:deck].shuffle!
  end

  def generate_pic_url(card)
    pic_name = case card[1]
               when 'H'
                 'hearts_' + card[0].to_s + '.png'
               when 'D'
                 'diamonds_' + card[0].to_s + '.png'
               when 'C'
                 'clubs_' + card[0].to_s + '.png'
               when 'S'
                 'spades_' + card[0].to_s + '.png'
               end

    pic_url = "<img src=/images/cards/#{ pic_name } class='card_pic'>"
  end
  
  def deal(hand)
    hand << session[:deck].pop
  end

  def calculate_total(hand)
    values = hand.map { |element| element[0] }

    total = 0

    values.each do |val|
      if val == 'ace'
        total += 11
      else
        total += val.to_i == 0 ? 10 : val.to_i
      end
    end

    values.select{|element| element == 'ace'}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def random_suit
    suits = ["&clubs;", "&diams;", "&hearts;", "&spades;"]
    a_suit = suits.sample
    a_suit
  end

end

get '/' do
  if session[:player_name]
    erb :bet
  else
    erb :index
  end
end

get '/name' do
  erb :name
end

post '/post_name' do
  session[:player_name] = params[:player_name]

  if session[:player_name] == ''
    @red = "<strong>Please</strong> enter a name."
    erb :name
  else
    redirect '/new_game'
  end
end

get '/new_game' do
  if session[:player_name]
    session[:player_turn] = true
    session[:player_hand] = []
    session[:player_cash] = 500
    session[:player_bet] = ''
    session[:dealer_hand] = []

    new_deck

    2.times do
      deal(session[:player_hand])
      deal(session[:dealer_hand])
    end

    redirect '/bet'
  else
    redirect '/name'
  end
end

get '/bet' do
  erb :bet
end

post '/post_bet' do
  session[:player_bet] = params[:player_bet].to_i
  if session[:player_bet] > 0 && session[:player_bet] <= session[:player_cash]

    redirect '/blackjack'
  else
    @red = "<strong>Invalid input</strong>"

    erb :bet
  end
end

get '/blackjack' do
  if calculate_total(session[:player_hand]) == BLACKJACK ||
    calculate_total(session[:dealer_hand]) == BLACKJACK
    case
    when calculate_total(session[:player_hand]) == BLACKJACK &&
      calculate_total(session[:dealer_hand]) == BLACKJACK
      session[:player_turn] = false
      @blue = "<strong>It's a Push!</strong> You and the Dealer both have Blackjack"
      erb :blackjack
    
    when calculate_total(session[:player_hand]) == BLACKJACK
      session[:player_turn] = false
      session[:player_cash] += session[:player_bet]
      @green = "<strong>Blackjack!</strong> You win!"
      erb :blackjack
    
    when calculate_total(session[:dealer_hand]) == BLACKJACK
      session[:player_turn] = false
      session[:player_cash] -= session[:player_bet]
      @red = "<strong>Dealer hits Blackjack</strong> You lose."
      if session[:player_cash] == 0
        @gameover = true
        erb :poorhouse
      else
        erb :blackjack
      end
    end
  else
    redirect '/busted'
  end
end

get '/busted' do
  if calculate_total(session[:player_hand]) > BLACKJACK ||
    calculate_total(session[:dealer_hand]) > BLACKJACK
    case
   
    when calculate_total(session[:player_hand]) > BLACKJACK
      session[:player_turn] = false
      session[:player_cash] -= session[:player_bet]
      @red = "<strong>You busted!</strong> Dealer wins"
      if session[:player_cash] == 0
        @gameover = true
        erb :poorhouse
      else
        erb :busted
      end
   
    when calculate_total(session[:dealer_hand]) > BLACKJACK
      session[:player_turn] = false
      session[:player_cash] += session[:player_bet]
      @green = "<strong>Dealer Busts</strong> You win!"
      erb :busted
    end
  else
    redirect '/hand/over'
  end
end

get '/hand/over' do
  if session[:player_turn] == false
    case
    when calculate_total(session[:player_hand]) >
      calculate_total(session[:dealer_hand])
      @green = "<strong>You win</strong> this hand!"
      session[:player_cash] += session[:player_bet]
      erb :over
   
    when calculate_total(session[:player_hand]) <
      calculate_total(session[:dealer_hand])
      session[:player_cash] -= session[:player_bet]
      @red = "<strong>Dealer wins</strong> this hand."
      if session[:player_cash] == 0
        @gameover = true
        erb :poorhouse
      else
        erb :over
      end
   
    when calculate_total(session[:player_hand]) ==
      calculate_total(session[:dealer_hand])
      @blue = "<strong>It's a Push</strong> You and the Dealer have the same score."
      erb :over
    end
  else
    redirect '/game'
  end
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
  if calculate_total(session[:dealer_hand]) < DEALER_STAY
    deal(session[:dealer_hand])
    redirect '/dealer/hit'
  else

    redirect '/blackjack'
  end
end

get '/game' do
  erb :game
end

post '/new_hand' do
  session[:player_turn] = true
  session[:player_hand] = []
  session[:dealer_hand] = []

  2.times do
    deal(session[:player_hand])
    deal(session[:dealer_hand])
  end

  redirect '/bet'
end

get '/about' do
  @gameover = true
  erb :about
end

get '/vegas' do
  session[:player_turn] = nil
  session[:player_hand] = nil
  session[:player_bet] = nil
  session[:dealer_hand] = nil
  @gameover = true
  erb :vegas
end

get '/poorhouse' do
  @gameover = true
  erb :poorhouse
end

get '/cat' do
  @gameover = true
  erb :cat
end

