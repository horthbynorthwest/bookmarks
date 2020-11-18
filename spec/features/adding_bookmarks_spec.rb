# require 'pg'

feature 'user can add a bookmark' do
  scenario 'A user can add a bookmark to Bookmark Manager' do
    visit('/bookmarks/new')
    fill_in('url', with: 'http://twitter.com')
    fill_in('title', with: 'Twitter')
    click_button('Submit')

    expect(page).to have_link('Twitter', href: 'http://twitter.com')
  end
end
