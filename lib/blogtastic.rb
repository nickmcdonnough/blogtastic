require 'pg'

require_relative 'blogtastic/repos/posts_repo.rb'
require_relative 'blogtastic/repos/comments_repo.rb'
require_relative 'blogtastic/repos/users_repo.rb'


module Blogtastic
  def self.create_db_connection(dbname)
    PG.connect(host: 'localhost', dbname: dbname)
  end

  def self.clear_db(db)
    db.exec <<-SQL
      DELETE FROM comments;
      DELETE FROM posts;
      DELETE FROM users;
    SQL
  end

  def self.create_tables(db)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS users(
        id SERIAL PRIMARY KEY,
        name VARCHAR,
        password VARCHAR,
        email VARCHAR
      );
      CREATE TABLE IF NOT EXISTS posts(
        id SERIAL PRIMARY KEY,
        title VARCHAR,
        content VARCHAR,
        user_id INT references users(id)
      );
      CREATE TABLE IF NOT EXISTS comments(
        id SERIAL PRIMARY KEY,
        content VARCHAR,
        user_id INT references users(id),
        post_id INT references posts(id)
      );
    SQL
  end

  def self.seed_db(db)
    db.exec <<-SQL
      INSERT INTO users (name, password) values ('anonymous', 'anonymous', 'anon@ymous.gov')
    SQL
  end

  def self.drop_tables(db)
    db.exec <<-SQL
      DROP TABLE comments;
      DROP TABLE posts;
      DROP TABLE users;
    SQL
  end
end

