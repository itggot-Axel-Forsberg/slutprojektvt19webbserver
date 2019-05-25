require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
require_relative 'model.rb'
include MyModule

helpers do
    # Selects and writes the error text corresponding to the type of error into session.
    # 
    # @error_type [String] String describing the type of error.
    #
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
# Sets which routes that are secured.
#
configure do
    set :secured_paths,["/cart", "/checkout","/store/","/profile","/delete/","/deleteorder/"]
end

# Checks if user is logged in before entering some selected routes.
#
# @session [Integer]:User_Id, the id of the user.
#
before do 
    if settings.secured_paths.any? {|elem| request.path.start_with?(elem)} 
        halt 403 unless session[:User_Id]
    end
end

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
# @see get_error
post('/register') do
    result = register(params)

    if result == true
        redirect('/login')
    else
        result = "registererror"
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
# @see Model#login
# @see get_error
post('/login') do
    result = login(params)
    if result == false
        result = "loginerror"
        get_error(result)
        redirect('/login')
    else
        session[:User], session[:User_Id] = login(params)
        redirect('/')   
    end
end

# Logs the user out by resetting session values.
#
post('/logout') do
    session[:User_Id] = nil
    session[:User] = nil
    redirect('/')
end

# Displays profile page containing orders the user has made.
#
# @see Model#user_orders
get('/profile') do
    user_orders = user_orders(session[:User_Id])

    slim(:profile, locals:{orders:user_orders})
end

post('/deleteorder/:order_id') do
    delete_order(params[:order_id])

    redirect('/profile')
end

# Displays items that can be purchased from database.
#
# @see Model#item_info
get('/store') do
    item = item_info()

    slim(:store, locals:{products:item})
end

# Adds a product to the orderlist to a new or already existing order.
# 
# @param [String] Name, Name of product
# @param [Int] Price, Price of the product
# @param [Int] Username, The username
#
# @see Model#new_order
# @see Model#add_orderitem
# @see get_error
post('/store/:item_id') do

    session[:orderid] = new_order(session[:User_Id])
    result = add_orderitem(params, session[:User_Id])
    if result == true
        redirect('/cart')
    else
        result = "itemerror"
        get_error(result)
        redirect('/store')
    end
end

# Displays items and price from the users active order. Creates an active order if there is none.
#
# @see Model#new_order
# @see Model#order_info
get('/cart') do 
    if session[:orderid] == nil
        session[:orderid] = new_order(session[:User_Id])
    end
    order = orderinfo(session[:orderid])
        
    slim(:cart, locals:{cart:order})
end

# Deletes an item from the users active order.
#
# @param [Integer] item_id, The id of the item to be delted from the order.
#
# @see Model#delete_orderitem
post('/delete/:item_id') do
    delete_orderitem(params["item_id"], session[:orderid], session[:User_Id])
    redirect('/cart')
end

# Redirects user to checkout page.
#
post('/cart') do
    redirect('/checkout')
end

# Displays a checkout form.
#
get('/checkout') do
    slim(:checkout)
end

# Finishes the users active order and redirects to home page.
#
# @see Model#checkout
post('/checkout') do
    checkout(session[:User_Id])
    redirect('/')
end

# Displays error 403 page.
#
error 403 do
    slim(:error403)
end