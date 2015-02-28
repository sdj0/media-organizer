gem "minitest"

require 'minitest/autorun'
require '/mnt/hgfs/Repositories/media-organizer/lib/scrapers/image.rb'
require '/mnt/hgfs/Repositories/media-organizer/lib/scrapers/music.rb'

class TestMusic < MiniTest::Test
	#music scraper tests
	def test_ismusic_validfile_supported
		assert(Music.is_music?("/mnt/hgfs/Repositories/media-organizer/test/data/Too Late to Topologize.mp3"))
	end

	def test_ismusic_validfile_unsupported
		assert(!Music.is_music?("/mnt/hgfs/Repositories/media-organizer/test/data/pic2.jpg"))
	end

	def test_ismusic_invalidfile
		assert(!Music.is_music?("/mnt/hgfs/Repositories/media-organizer/test/data/macabre_kebab_asdfasdf"))		
	end


	#image scraper tests

	def test_isimage_validfile_supported
		assert(Image.is_image?("/mnt/hgfs/Repositories/media-organizer/test/data/pic2.jpg"))
	end

	def test_isimage_validfile_unsupported
		assert(!Image.is_image?("/mnt/hgfs/Repositories/media-organizer/test/data/Too Late to Topologize.mp3"))
	end

	def test_isimage_invalidfile
		assert(!Image.is_image?("/mnt/hgfs/Repositories/media-organizer/test/data/macabre_kebab_asdfasdf"))		
	end

end

