require 'sqlite3'

class Recipes

  def self.db
    return @db if @db
    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true

    return @db
  end

  def self.all()
    return db.execute('SELECT * FROM recipes')
  end

  def self.find(id)
    return db.execute('SELECT * FROM recipes WHERE id=?', [id.to_i]).first
  end

  def self.delete(id)
    db.execute('DELETE FROM recipes WHERE id=?', [id.to_i])
  end 

  def self.delete_user(userid)
    db.execute('DELETE FROM recipes WHERE userid=?', [userid])
  end 

  def self.create(name, description, time, category, userid)
    db.execute('INSERT INTO recipes(name, description, time, category, userid) VALUES(?,?,?,?,?)', [name, description, time, category.to_i, userid.to_i])
  end 

  def self.update(name, description, time, category, id)
    db.execute('Update recipes Set name=?, description=?, time=?, category=? Where id=?', [name, description, time, category, id])
  end 

end 