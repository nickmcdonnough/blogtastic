module Blogtastic
  class PostsRepo
    def self.all db
      sql = %q[SELECT * FROM posts]
      result = db.exec(sql)
      result.entries
    end
  
    def self.find db, id
      sql = %q[SELECT * FROM posts WHERE id = $1]
      result = db.exec(sql, [id])
      result.first
    end
  
    def self.save db, post_data
      if post_data[:id]
        sql = %q[UPDATE posts SET content = $1 WHERE id = $2 RETURNING *]
        result = db.exec(sql, [post_data[:content], post_data[:id]])
      else
        sql = %q[INSERT INTO posts (title, content, user_id) values ($1, $2, $3) RETURNING *]
        result = db.exec(sql, [post_data[:title], post_data[:content], post_data[:user_id]])
      end
  
      result.first
    end
  
    def self.destroy db, id
      sql = %q[DELETE FROM posts where id = $1]
      db.exec(sql, [id])
      post_exists?(db, id)
    end
  
    private
  
    def self.post_exists? db, id
      result = find db, id
      !!result.first
    end
  end
end
