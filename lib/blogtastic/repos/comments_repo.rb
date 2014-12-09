module Blogtastic
  class CommentsRepo
    def self.all db
      sql = %q[SELECT * FROM comments]
      result = db.exec(sql)
      result.entries
    end

    def self.find db, id
      sql = %q[SELECT * FROM comments WHERE id = $1]
      result = db.exec(sql, [id])
      result.first
    end

    def self.post_comments db, post_id
      sql = %q[SELECT * FROM comments WHERE post_id = $1]
      result = db.exec(sql, [post_id])
      result.entries
    end

    def self.save db, comment_data
      unless comment_data['id']
        sql = %q[INSERT INTO comments (content, user_id, post_id) values ($1, $2, $3) RETURNING *]
        result = db.exec(sql, [comment_data[:content], comment_data[:user_id], comment_data[:post_id]])
        result.first
      end
    end

    def self.destroy db, id
      sql = %q[DELETE FROM comments where id = $1]
      db.exec(sql, [id])
      comment_exists?(db, id)
    end

    private

    def self.comment_exists? db, id
      result = find db, id
      !!result.first
    end
  end
end
