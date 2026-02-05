require 'sqlite3'

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
  end

  def self.create_tables
    db.execute('CREATE TABLE recipes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                ingredients TEXT,
                description TEXT,
                time INTEGER)')
  end

  def self.populate_tables
    db.execute('INSERT INTO recipes (name, ingredients, description, time) VALUES ("Chokladbollar", kokos , "Enkla svenska Chokladbollar", "40")')
    db.execute('INSERT INTO recipes (name, ingredients, description, time) VALUES ("Chokladbollar", kokos , "Enkla svenska Chokladbollar", "40")')
    db.execute('INSERT INTO recipes (name, ingredients, description, time) VALUES ("Chokladbollar", kokos , "Enkla svenska Chokladbollar", "40")')
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
