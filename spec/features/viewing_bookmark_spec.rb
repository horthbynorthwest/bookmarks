feature 'viewing bookmarks' do
  scenario 'visting the index page' do
    visit('/')
    expect(page.status_code).to eq(200)
    expect(page).to have_content "Bookmark Manager"
  end

  scenario 'visiting the bookmarks page' do
   # Add the test data
   Bookmark.create(url:'http://www.makersacademy.com', title: 'Makers')
   Bookmark.create(url:'http://www.destroyallsoftware.com', title: 'Destroy All Software')
   Bookmark.create(url: 'http://www.google.com', title: 'Google')
    visit('/bookmarks')
    expect(page).to have_link('Makers', href: 'http://www.makersacademy.com')
    expect(page).to have_link('Destroy All Software', href: 'http://www.destroyallsoftware.com')
    expect(page).to have_link('Google', href: 'http://www.google.com')
  end
end
