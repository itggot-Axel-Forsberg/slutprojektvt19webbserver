require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
#enable :sessions
require_relative('model.rb')

get('/') do
    slim(:index)
end

get('/register') do
    slim(:register)
end

post('/register') do
    register(params)

    redirect('/login')
end

get('/login') do
    slim(:login)
end

post('/login') do
    session[:User], session[:User_Id] = login(params)
    redirect('/')
end