require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative('model.rb')
#include MyModule
#Model::Post.create_post(data)

# Display Landing Page
#
get('/') do
    slim(:index)
end

# Displays a register form
#
get('/register') do
    slim(:register)
end
# Attempts to register
# @param [String] Username, The username
# @param [String] Email, the users Email 
# @param [String] Password, The password
#
# @see Model#register
post('/register') do
    if register(params) == true
        redirect('/login')
    else
        redirect('/register_error')
    end
end
# Displays a login form
#
get('/login') do
    slim(:login)
end

# Attempts login and updates the session
# @param [String] Username, The username
# @param [String] Password, The password
#
# see Model#login
post('/login') do
    if login(params) == false
        redirect('/login_error')
    else
    session[:User], session[:User_Id] = login(params)
    redirect('/')
end

# Displays login form with error message
#
get('/login_error') do
    slim(:login_error)
end

# Displays items that can be purchasedfrom database
#
get('/store') do
    db = connect_db()
    item = db.execute("SELECT * FROM items")

    slim(:store, locals:{products:item})
end

# Adds a product as an order
# 
# @param [String] Name, Name of product
# @param [Int] Price, Price of the product
# @param [Int] Username, The username
#

post('/store/:item_id') do
    add_order(params)
    redirect('/orders')
end

# 
get('/order') do 
    #VEM är inloggad?
    #vad har hen för cart?
    #hämta cart
    #hämta lineitems för cart
    slim(:cart)
end

post('/cart') do 
end