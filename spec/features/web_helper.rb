def add_a_bookmark
  visit('/bookmarks/new')
  fill_in('url', with: 'http://twitter.com')
  fill_in('title', with: 'Twitter')
  click_button('Submit')
end
