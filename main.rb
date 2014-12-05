require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000, # In seconds
                           :secret => 'Sj4R#CnTeUOFGQX%XK'

helpers do
  def link(name)
    case name
    when :form then '/form'
    when :cat then '/cat'
    end
  end
end

get '/' do
  erb :index
end

get '/form' do
  erb :form
end

get '/cat' do
  erb :cat
end

post '/getname' do
  session[:username] = params[:username]
  redirect '/bet'
end

post '/bet' do
  session[:cash] = 500
  session[:username] = params[:username]
  erb :bet
  redirect '/game'
end

get '/game' do
  session[:deck] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'].product(['C', 'D', 'H', 'S'])
  session[:deck].shuffle!
  erb :game
end
