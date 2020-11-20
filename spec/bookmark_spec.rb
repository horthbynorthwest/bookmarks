require 'bookmark'
require 'database_helpers'


describe Bookmark do
  describe '.all' do
    it 'returns all bookmarks' do
      connection = PG.connect(dbname: 'bookmark_manager_test')

      # Add the test data
      bookmark =  Bookmark.create(url:'http://www.makersacademy.com', title: 'Makers')
      Bookmark.create(url:'http://www.destroyallsoftware.com', title: 'Destroy All Software')
      Bookmark.create(url: 'http://www.google.com', title: 'Google')
      bookmarks = Bookmark.all

      expect(bookmarks.length).to eq 3
      expect(bookmarks.first).to be_a Bookmark
      expect(bookmarks.first.id).to eq bookmark.id
      expect(bookmarks.first.title).to eq 'Makers'
      expect(bookmarks.first.url).to eq 'http://www.makersacademy.com'
    end
  end

  describe '.create' do
    it 'creates a new bookmark' do
      bookmark = Bookmark.create(url: 'http://twitter.com', title: 'Twitter')
      persisted_data = persisted_data(id: bookmark.id)

      expect(bookmark).to be_a Bookmark
      expect(bookmark.id).to eq persisted_data['id']
      expect(bookmark.url).to eq 'http://twitter.com'
      expect(bookmark.title).to eq 'Twitter'
    end
  end

  describe '.delete' do
    it 'deletes a bookmark' do
      bookmark = Bookmark.create(url: 'http://twitter.com', title: 'Twitter')
      persisted_data = persisted_data(id: bookmark.id)
      expect { Bookmark.delete(id: bookmark.id) }.to change { Bookmark.all.length }.by -1
    end
  end

  describe '.edit' do
    it 'edits a bookmark' do
      bookmark = Bookmark.create(url: 'http://twitter.com', title: 'Twitter')
      updated_bookmark = Bookmark.edit(id: bookmark.id, url: 'www.amazon.co.uk', title: 'Amazon')

      expect(updated_bookmark).to be_a Bookmark
      expect(updated_bookmark.id).to eq bookmark.id
      expect(updated_bookmark.title).to eq 'Amazon'
      expect(updated_bookmark.url).to eq 'www.amazon.co.uk'
    end
  end

  describe '.find' do
    it 'returns the requested bookmark object' do
      bookmark = Bookmark.create(url: 'http://twitter.com', title: 'Twitter')

      result = Bookmark.find(id: bookmark.id)

      expect(result).to be_a Bookmark
      expect(result.id).to eq bookmark.id
      expect(result.title).to eq 'Twitter'
      expect(result.url).to eq 'http://twitter.com'
    end
  end
end
