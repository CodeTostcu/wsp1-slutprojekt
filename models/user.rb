require 'sqlite3'

class Users

  def self.db
    return @db if @db
    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true

    return @db
  end

  def self.all(username)
    db.execute("SELECT * FROM users WHERE username = ?", [username]).first
  end 

  def self.find(id)
   return db.execute("SELECT * FROM users WHERE id = ?", [id]).first
  end 

  def self.create(username, password)
    db.execute('INSERT INTO users(username, password) VALUES(?,?)', [username, password])
  end 

  def self.delete(id)
    db.execute('DELETE FROM users WHERE id=?', [id])
  end 

  def self.update(username, id)
    db.execute('UPDATE users SET username=? WHERE id=?', [username, id])
  end 

  def self.find_user(username, id)
    return db.execute("SELECT * FROM users WHERE username = ? AND id != ?",[username, id]).first
  end 

  
end 