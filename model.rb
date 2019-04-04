require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

def connect_db()
    db = SQLite3::Database.new('db/store.db')
    db.results_as_hash = true
    return db
end

def register(params)
    if params["Username"] && params["Email"] && params["Password"] != nil

        db = connect_db()
        hashat_password = BCrypt::Password.create(params["Password"])

        db.execute("INSERT INTO Username, Email, Password VALUES(?, ?, ?)", params["Username"], params["Email"], hashat_password)
        return true
    else
        return false
    end
end

def login(params)
    db = SQLite3::Database.new('db/Users.db')
    db.results_as_hash = true
    pass_crypt = db.execute("SELECT Password, User_Id FROM Users WHERE Username = ?",params["Username"])
    
    if (BCrypt::Password.new(pass_crypt.first["Password"]) == params["Password"]) == true
        return params["Username"], params["User_Id"]
    else
        return false
    end
end