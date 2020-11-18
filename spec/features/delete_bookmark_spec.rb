feature 'user can delete a bookmark' do
  scenario 'A user can press delete button' do
    add_a_bookmark

    expect(page).to have_button('delete')
  end
  scenario 'A user can delete a bookmark from Bookmark Manager' do
    add_a_bookmark
    click_button('delete')

    expect(page.status_code).to eq(200)
    expect(page).to_not have_link('Twitter', href: 'http://twitter.com')
  end
end
