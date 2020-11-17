require 'pg'

feature 'viewing bookmarks' do
  scenario 'visting the index page' do
    visit('/')
    expect(page).to have_content "Bookmark Manager"
  end

  scenario 'visiting the bookmarks page' do
   # Add the test data
   Bookmark.create(url:'http://www.makersacademy.com')
   Bookmark.create(url:'http://www.destroyallsoftware.com')
   Bookmark.create(url: 'http://www.google.com')
    visit('/bookmarks')
    expect(page).to have_content "http://www.makersacademy.com"
    expect(page).to have_content "http://www.destroyallsoftware.com"
    expect(page).to have_content "http://www.google.com"
  end
end
