
feature 'user can edit a bookmark' do
  scenario 'A user can press edit button' do
    add_a_bookmark

    expect(page).to have_button('Edit')
  end

  scenario 'A user can edit a bookmark in Bookmark Manager' do
    add_a_bookmark
    click_button('Edit')
    fill_in('title', with: 'Amazon')
    fill_in('url', with: 'www.amazon.co.uk')
    click_button('Submit')

    expect(page.status_code).to eq(200)
    expect(page).to_not have_link('Twitter', href: 'http://twitter.com')
    expect(page).to have_link('Amazon', href: 'www.amazon.co.uk')
  end
end
