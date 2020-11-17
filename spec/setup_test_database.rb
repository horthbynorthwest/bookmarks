require 'pg'
def setup_test_database
  p "setting up test database..."

  connection = PG.connect(dbname: 'bookmark_manager_test')

# clear the bookmarks table
  connection.exec("TRUNCATE bookmarks;")
end 
