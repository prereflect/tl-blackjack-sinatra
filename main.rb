require 'sinatra'

set :sessions, true

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
  session[:cash] = 500
  redirect '/bet'
end

get '/bet' do
  erb :bet
end
