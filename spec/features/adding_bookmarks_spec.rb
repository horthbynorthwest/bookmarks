require 'pg'

feature 'user can add a bookmark' do
  scenario 'A user can add a bookmark to Bookmark Manager' do
    visit('/bookmarks/new')
    fill_in('url', with: 'http://twitter.com')
    click_button('Submit')

    expect(page).to have_content 'http://twitter.com'
  end
end 
