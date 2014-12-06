require 'sinatra'
require "sinatra/reloader" if development?

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'Sj4R#CnTeUOFGQX%XK'

helpers do
  def new_player
    session[:player_name] = 'Anon'
    session[:player_cash] = 500
    session[:player_hand] = []
    session[:player_bet] = []
  end

  def new_deck
    session[:deck] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'].product(['C', 'D', 'H', 'S'])
    session[:deck].shuffle!
  end
  
  def deal(hand)
    hand << session[:deck].pop
  end

  def link(name)
    case name
    when :name then '/name'
    when :cat then '/cat'
    end
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

  deal(session[:player_hand])
  deal(session[:dealer_hand])
  deal(session[:player_hand])
  deal(session[:dealer_hand])

  erb :game
end
