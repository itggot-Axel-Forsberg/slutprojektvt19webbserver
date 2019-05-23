require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
module MyModule
    def connect_db()
        db = SQLite3::Database.new('db/store.db')
        db.results_as_hash = true
        return db
    end
#se till att rätt format skrivs in vid insert funktioner.
    def register(params)
        byebug
        unless params["Username"] == "" or params["Email"] == "" or params["Password"] == ""
            if params["Username"] && params["Email"] && params["Password"]
                
                db = connect_db()
                hashat_password = BCrypt::Password.create(params["Password"])

                db.execute("INSERT INTO users(Username, Email, Password) VALUES(?, ?, ?)", params["Username"], params["Email"], hashat_password)
                return true
            else
                return false
            end
        end
    end

    def login(params)
        db = connect_db()
        user_info = db.execute("SELECT Password, User_Id FROM users WHERE Username = ?",params["Username"])
        username = params["Username"] 
        if (BCrypt::Password.new(user_info.first["Password"]) == params["Password"]) == true
            user_id = user_info.first["User_Id"]
            return [username, user_id]
        else
            return false
        end
    end

    def new_order(user_id)
        db = connect_db()
        status = "unpaid"
        if db.execute("SELECT * FROM orders WHERE User_Id = ? AND Status = ?", user_id, status) == []
            #ta datum och sätt in
            db.execute("INSERT INTO orders(User_Id, Price, Status) VALUES(?, 0, ?)", user_id, status)
        else
        end
        orderid = db.execute("SELECT Order_Id FROM orders WHERE User_Id = ? AND Status = ?", user_id, status).first
        return orderid["Order_Id"]
    end

    def add_orderitem(params, user_id)
        db = connect_db()
        order = db.execute("SELECT Order_Id, Price FROM orders WHERE User_Id = ?", user_id).first
        new_item = db.execute("SELECT Item_Name, Price FROM items WHERE Item_Id = ?", params[:item_id]).first
        db.execute("INSERT INTO orderitem(Order_Id, Item_Id, Order_Name, Price, Amount) VALUES(?, ?, ?, ?, ?)", order["Order_Id"], params[:item_id].to_i, new_item["Item_Name"], new_item["Price"], params[:amount].to_i)
        order["Price"] += new_item["Price"] * params[:amount].to_i
        db.execute("UPDATE orders SET Price=?", order["Price"])
    end

    def item_info()
        db = connect_db()
        items = db.execute("SELECT * FROM items")
        return items
    end

    def orderinfo(orderid)
        db = connect_db()
        orderinfo = db.execute("SELECT Order_Id, Order_Name, Price, Amount FROM orderitem WHERE Order_Id = ?", orderid)
        return orderinfo
    end

    def checkout(user_id)
        db = connect_db()
        status_unpaid = "unpaid"
        status_paid = "paid"
        db.execute("UPDATE orders SET Status = ? WHERE User_Id = ? AND Status = ?", status_paid, user_id, status_unpaid)
    end
end