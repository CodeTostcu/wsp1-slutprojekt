require 'sqlite3'

class Groups

  def self.db
    return @db if @db
    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true

    return @db
  end

  def self.all()
    return db.execute('SELECT * FROM groups')
  end

  def self.find_user(userid)
    return db.execute('SELECT * FROM groups INNER JOIN group_members ON groups.id = group_members.groupid WHERE group_members.userid = ?', [userid])
  end

  def self.find_group(userid)
    return db.execute('SELECT * FROM groups WHERE id NOT IN (SELECT groupid FROM group_members WHERE userid = ?)', [userid])
  end

  def self.find_user_in_group(id)
    return db.execute('SELECT * FROM users INNER JOIN group_members ON users.id = group_members.userid WHERE group_members.groupid = ?',[id])
  end 

  def self.join(userid, groupid)
    db.execute('INSERT INTO group_members (userid, groupid) VALUES (?,?)', [userid, groupid])
  end 

end 