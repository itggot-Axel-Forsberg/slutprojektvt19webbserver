require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

def login()
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true
    pass_crypt = db.execute("SELECT Password, User_Id FROM Users WHERE Username = ?",params["Username"])
    
    if (BCrypt::Password.new(pass_crypt.first["Password"]) == params["Password"]) == true
        session[:User] = params["Username"]
    
        logged_in= true
    else
        logged_in= false
    end
end