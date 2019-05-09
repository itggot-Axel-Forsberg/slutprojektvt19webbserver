require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative('model.rb')

get('/') do
    slim(:index)
end

get('/register') do
    slim(:register)
end

post('/register') do
    if register(params) == true
        redirect('/login')
    else
        redirect('/register_error')
    end
end

get('/login') do
    slim(:login)
end

post('/login') do
    
    session[:User], session[:User_Id] = login(params)
    redirect('/')
end

get('/store') do
    db = connect_db()
    item = db.execute("SELECT * FROM items")

    slim(:store, locals:{products:item})
end

post('/store/:item_id') do
    byebug
    add_order(params)
    redirect('/orders')
end

get('/cart') do 
    #VEM är inloggad?
    #vad har hen för cart?
    #hämta cart
    #hämta lineitems för cart
    slim(:cart)
end

post('/cart') do 
end