module Blogtastic
  class UsersRepo
    def self.find db, user_id
      sql = %q[SELECT * FROM users WHERE id = $1]
      result = db.exec(sql, [user_id])
      result.first
    end

    def self.save db, user_data
      # TODO: save user's info when they sign up.
      #       should include username, password, email
    end
  end
end
