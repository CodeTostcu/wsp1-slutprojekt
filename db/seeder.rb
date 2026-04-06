require 'sqlite3'
require 'bcrypt'

class Seeder

  def self.seed!
    puts "Using db file: #{DB_PATH}"
    puts "🧹 Dropping old tables..."
    drop_tables
    puts "🧱 Creating tables..."
    create_tables
    puts "🍎 Populating tables..."
    populate_tables
    puts "✅ Done seeding the database!"
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS recipes')
    db.execute('DROP TABLE IF EXISTS users')

    db.execute('DROP TABLE IF EXISTS groups')
  end

  def self.create_tables
    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                password TEXT NOT NULL)')

   
    db.execute('CREATE TABLE recipes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                time INTEGER,
                category INTEGER, 
                userid INTEGER)')

    db.execute('CREATE TABLE groups (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                userid)')
  end

  def self.populate_tables
    password_hashed = BCrypt::Password.create("123")
    p "Storing hashed password (#{password_hashed}) to DB. Clear text password (123) never saved."

    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Korven", password_hashed])
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["Anna", password_hashed])
    
    db.execute("INSERT INTO recipes (name, description, time, category, userid) VALUES ('choklad', 'Hej', 10, 0, 1)")
  end

  private

  def self.db
    return @db if @db
    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!