require 'sinatra'
require "sinatra/reloader" if development?

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'Sj4R#CnTeUOFGQX%XK'

 BLACKJACK = 21
 DEALER_STAY = 17

helpers do
  def player
    session[:player_cash] = 500
    session[:player_hand] = []
    session[:player_bet] = ''
  end

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
end

get '/' do
  erb :index
end

get '/new_game' do
  new_deck
  player
  session[:dealer_hand] = []
  2.times do
    deal(session[:player_hand])
    deal(session[:dealer_hand])
  end
  redirect '/name'
end

get '/name' do
  erb :name
end

post '/post_name' do
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/post_bet' do
  session[:player_bet] = params[:player_bet].to_i
  redirect '/game'
end

post '/player/hit' do
  deal(session[:player_hand])
  redirect '/game'
end

get '/game' do
  erb :game
end

get '/cat' do
  erb :cat
end

