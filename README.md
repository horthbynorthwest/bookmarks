# Bookmarks
### Week 4 afternoon challenge

Hi! In this afternoon challenge we are creating a web Bookmark Manager with database integration.

Our website will have the following specifications:

-   Show a list of bookmarks
-   Add new bookmarks
-   Delete bookmarks
-   Update bookmarks
-   Comment on bookmarks
-   Tag bookmarks into categories
-   Filter bookmarks by tag
-   Users are restricted to manage only their own bookmarks

We'll be using BDD (Behaviour Driven Development) to deliver this website.

### User Story 1

We wrote our first user story as:

    As a user 
    So I can see my saved bookmarks 
	I’d like to be able to pull up a list of bookmarks

As a part of this user story we created a simple domain model to act as structure that we'd be aiming for.

<img width="992" alt="Screenshot 2020-11-16 at 14 46 16" src="https://user-images.githubusercontent.com/71782749/99295211-08c24e80-283d-11eb-8ee4-5c8d7fbe0167.png">

First, we made sure that we'd followed [all of the steps](https://github.com/makersacademy/course/blob/master/pills/ruby_web_project_setup_list.md) of setting up a sinatra app, making our feature test pass with the smallest amount of code written. 

We refactored our working from a hardcoded array to a Class method def self.all :

  ```ruby 
# in lib/bookmark.rb
    
    class Bookmark
	  def self.all
	     [
	      "http://www.makersacademy.com",
	      "http://www.destroyallsoftware.com",
	      "http://www.google.com"
	     ]
	  end
    end
```
The app.rb route looks like:
```ruby
   get '/bookmarks' do
	  @bookmarks = Bookmark.all
	  erb :'bookmarks/index'
    end
```
The erb iterates over the @bookmarks array using each. This concludes User Story 1.

### User Story 2

```
As a time-pressed user
So that I can save a website
I would like to add the site's address and title to bookmark manager
```

For this our first approach was to create a database in PostgreSQL. Our bookmarks table was created using the following settings:

```
bookmark_manager=# CREATE TABLE bookmarks(id SERIAL PRIMARY KEY, url VARCHAR(60));
```

Downloading PG allowed us to connect to a database within ruby. We altered our self.all method to allow integration with the database. Our method now looks like:

```ruby
class Bookmark
  def self.all
    connection = PG.connect(dbname: 'bookmark_manager')
    result = connection.exec('SELECT * FROM bookmarks')
    result.map { |bookmark| bookmark['url'] }
  end
end
```

In this method we are creating a connection to the database, then calling the correct table using a query. Finally we assigned the query to a variable which we then mapped over to result in an array of urls. By doing this we only had to change the code in our bookmark.rb file, we did not change anything in our erb, spec or app files.
 
 ### Setting up a test environment

This ultimately allows us to test things without affecting our development environment (booting up with rackup). There are several steps to this

 - Create a test database
 - Setting a ENV to test
 - Update our code to be able to connect to both
 - Truncating our table between tests
 
#### Creating a test database
To do this we followed the same steps as before only we called this this database 'bookmark_manager_test'. The table is still called 'bookmarks' 

#### Setting the ENV to test
In the spec_helper.rb file we added an ENV setter. This is as the spec_helper file is the first thing run when we run rspec. This allows us to set the environment when running tests. 

```ruby
#in spec/spec_helper.rb
ENV['ENVIRONMENT'] = 'test'
```
#### Adapting our code
Now we have two databases and two environments, we need to update our code so that it can connect to both and connects to the correct database when we want it to.

This can be achieved with a if/else statement.

```ruby
#in lib/bookmark.rb

if ENV['ENVIRONMENT'] == 'test'
      connection = PG.connect(dbname: 'bookmark_manager_test')
    else
      connection = PG.connect(dbname: 'bookmark_manager')
end
```
This simply says that if the ENV is set to test (i.e. we're running rspec) it'll connect to the bookmark_manager_test database, otherwise it'll connect to our first database.

This will mean that the line after else will not be covered by tests. This is ok as we don't want our tests to touch it!

#### Wiping our table in between tests
It's important that our table is cleared between tests, we don't want to have to work out what requirements we need to have based on what tests have been run before hand. 

Here we wrote a helper that clears the table and we then set it in a before block in spec helper. 

First step first. How do we write the code to wipe the table. We use TRUNCATE the table. There is another option called DROP but that will completely the delete the table rather than just wiping it clean.

```ruby
#we create a new file /spec/setup_test_database.rb
require 'pg'

def set_up_database
	p "Setting up test database..."

	connection = PG.connect(dbname: 'bookmark_manager_test')

# Clear the bookmarks table
	connection.exec("TRUNCATE bookmarks;")
end
```
This would work fine but we would have to run it and then run a specific rspec test which becomes slow and very painful. In spec_helper let's add in a before do clause to make it automatic

require_relative './setup_test_database'

```ruby
#in spec/spec_helper.rb

RSpec.configure do |config|
  config.before(:each) do
    setup_test_database
  end
end
```
Now, when we run rspec, we'll see "Setting up test database..." between each test. 

Wiping the table means that we need to set up each test individually with test data in the database.

### User Story 3

```
As a user
So I can store bookmark data for later
I want to add a bookmark to Bookmark Manager
```
For this we are expecting to enact:
-   Visiting a page,  `/bookmarks/new`
-   Typing a URL into a form on that page
-   Submitting the form
-   Seeing the bookmark they just submitted.

#### Feature test!
First up is the feature test, which looks something like:
```ruby
# in spec/features/creating_bookmarks_spec.rb

feature 'Adding a new bookmark' do
  scenario 'A user can add a bookmark to Bookmark Manager' do
    visit('/bookmarks/new')
    fill_in('url', with: 'http://testbookmark.com')
    click_button('Submit')

    expect(page).to have_content 'http://testbookmark.com'
  end
end
```
To make the first error pass we need to create a path '/bookmaks/new'

```ruby
# in app.rb

get '/bookmarks/new' do
  erb :"bookmarks/new"
end
```

Next, we create the erb page which contains a form that the user can fill out

```
<!-- inside views/bookmarks/new.erb -->

<form action="/bookmarks" method="post">
  <input type="text" name="url" />
  <input type="submit" value="Submit" />
</form>
```
The url name is so our Capybara test can find it. We've added in the method as post and the route as '/bookmarks' this is following restful practices. The same url can have many different routes. 

If we run our test now, it'll fail as we don't have a post '/bookmarks' route set up, so lets do this now.

```ruby
#in app.rb
post '/bookmarks' do
  url = params['url']
  connection = PG.connect(dbname: 'bookmark_manager_test')
  connection.exec("INSERT INTO bookmarks (url) VALUES('#{url}')")
  redirect '/bookmarks'
end
```
Here we have hard coded in the link to the test database, don't worry, we'll fix this as we get add the functionality in our bookmark.rb file.

After we've added the data we redirect to get '/bookmark' where the addition will now be displayed. This passes the feature test.

#### Unit test!
First, we write our unit test:

```ruby 
describe '.create' do
  it 'creates a new bookmark' do
    Bookmark.create(url: 'http://www.testbookmark.com')

    expect(Bookmark.all).to include 'http://www.testbookmark.com'
  end
end
```

Seeing as we already have a line of code that passes this url into the database we can create this method very easily

```ruby
#in bookmark.rb
  
def self.create(url:)
  if ENV['ENVIRONMENT'] == 'test'
    connection = PG.connect(dbname: 'bookmark_manager_test')
  else
    connection = PG.connect(dbname: 'bookmark_manager')
  end

  connection.exec("INSERT INTO bookmarks (url) VALUES('#{url}')")
end
```
 This should pass our unit test. Now we can refactor our app.rb file to contain this new syntax
```ruby
post '/bookmarks' do
  Bookmark.create(url: params[:url])
  redirect '/bookmarks'
end
```

This now passes all our tests up to this point.

Now that we have a working .create method we can update how we add data to our database to use this.

```ruby
# in spec/features/viewing_bookmarks_spec.rb

   scenario 'Visiting /bookmarks shows me all the bookmarks' do
-    connection = PG.connect(dbname: 'bookmark_manager_test')
-
     # Add the test data
-    connection.exec("INSERT INTO bookmarks (url) VALUES ('http://www.makersacademy.com');")
-    connection.exec("INSERT INTO bookmarks (url) VALUES('http://www.destroyallsoftware.com');")
-    connection.exec("INSERT INTO bookmarks (url) VALUES('http://www.google.com');")
+    Bookmark.create(url: "http://www.makersacademy.com")
+    Bookmark.create(url: "http://www.destroyallsoftware.com")
+    Bookmark.create(url: "http://www.google.com")

visit('/bookmarks')

### the rest of the test ###
```
This makes our tests much easier to read.
