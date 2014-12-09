require 'sinatra'
require "sinatra/reloader" if development?

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'Sj4R#CnTeUOFGQX%XK'

 BLACKJACK = 21
 DEALER_STAY = 17

helpers do
  def new_player
    session[:player_name] = ''
    session[:player_cash] = 500
    session[:player_hand] = []
    session[:player_bet] = []
  end

  def new_deck
    session[:deck] = [
      2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'].product(
      ['C', 'D', 'H', 'S'])
    session[:deck].shuffle!
  end
  
  def deal(hand)
    hand << session[:deck].pop
  end
  
  def calculate_total(hand)
    values = hand.map { |element| element[0] }

    total = 0
    values.each do |val|
      if val == 'A'
        total += 11
      else
        total += val.to_i == 0 ? 10 : val.to_i
      end
    end

    values.select{|element| element == 'A'}.count.times do
      break if total <= 21
      total -= 10
    end
    
    total
  end
end

get '/' do
  erb :index
end

get '/cat' do
  erb :cat
end

get '/name' do
  erb :name
end

post '/set_name' do
  new_player
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/make_bet' do
  session[:player_bet] = params[:player_bet].to_i
  redirect '/game'
end

get '/game' do
  new_deck
  session[:dealer_hand] = []

  2.times do
    deal(session[:player_hand])
    deal(session[:dealer_hand])
  end

  erb :game
end

get '/new_game' do
  new_deck
  session[:player_cash] = 500
  session[:player_hand] = []
  session[:player_bet] = []
  redirect '/bet'
end
