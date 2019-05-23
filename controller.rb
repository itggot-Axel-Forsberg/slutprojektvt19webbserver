require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative 'model.rb'
include MyModule
#Model::Post.create_post(data)

# Display Landing Page
#


helpers do
    def get_error(error_type)
        if error_type == "registererror"
            session[:error] = "You entered incorrect register credentials. Please try again."
        elsif error_type == "loginerror"
            session[:error] = "You entered incorrect login credentials, or you haven't registered."
        else
            session[:error] = "The amount of products must be 1 or more"
        end
    end
end
#Checks if user is logged in before entering some selected routes.
#
configure do
    set :secured_paths,["/cart", "/checkout","/store/"]
end

before do 
    if settings.secured_paths.any? {|elem| request.path.start_with?(elem)} 
        halt 403 unless session[:User_Id]
    end
end

get('/') do
    slim(:index)
end

# Displays a register form
#
get('/register') do
    slim(:register)
end

get('/register_error') do 
    slim(:register_error)
end
# Attempts to register
# @param [String] Username, The username
# @param [String] Email, the users Email 
# @param [String] Password, The password
#
# @see Model#register
post('/register') do
    result = register(params)

    if result == true
        redirect('/login')
    else
        get_error(result)

        redirect('/register')
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
    result = login(params)
    if result[2] == true
        session[:User], session[:User_Id] = login(params)
        redirect('/')   
    else
        get_error(result)
        redirect('/login')
    end
end

# Displays login form with error message
#
get('/login_error') do
    slim(:login_error)
end

# Displays items that can be purchased from database
#
get('/store') do
    db = connect_db()
    item = item_info()

    slim(:store, locals:{products:item})
end

# Adds a product as an order
# 
# @param [String] Name, Name of product
# @param [Int] Price, Price of the product
# @param [Int] Username, The username
#
post('/store/:item_id') do

    session[:orderid] = new_order(session[:User_Id])
    result = add_orderitem(params, session[:User_Id])
    if result == true
        redirect('/cart')
    else
        get_error(result)
        redirect('/store')
    end
end

# 
get('/cart') do 
    #VEM är inloggad?
    #vad har hen för cart?
    #hämta cart
    #hämta orderitems för cart
    order = orderinfo(session[:orderid])
        
    slim(:cart, locals:{cart:order})
    
end

post('/cart') do
    redirect('/checkout')
end

get('/checkout') do
    slim(:checkout)
end

post('/checkout') do
    checkout(session[:User_Id])
    redirect('/')
end

error 403 do
    slim(:error403)
end