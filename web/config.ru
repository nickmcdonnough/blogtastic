require './server'

# set up db tables
db = Blogtastic.create_db_connection 'blogtastic'
Blogtastic.create_tables db

# run web app
run Blogtastic::Server
