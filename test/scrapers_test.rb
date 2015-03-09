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


	def test_music_availableMetadata
		mp3 = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Too Late to Topologize.mp3"
		m4a = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Tori Amos - 12 - Little Earthquakes.m4a"
		flac = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Denali - The Instinct - 05 - Do Something.flac"
		wav = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/09-Infinity.wav"

		mp3meta = Music.availableMetadata(mp3)
		assert_equal("Zammuto", mp3meta[:artist])
		m4ameta = Music.availableMetadata(m4a)
		assert_equal("Tori Amos", m4ameta[:artist])
		#flacmeta = Music.availableMetadata(flac)
		#assert_equal("Denali", flacmeta[:artist])
		#wavmeta = Music.availableMetadata(wav)
		#assert_equal("The XX", wavmeta[:artist])
	end

	def test_music_writeMetadata
		mp3 = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Too Late to Topologize.mp3"
		m4a = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Tori Amos - 12 - Little Earthquakes.m4a"
		
		assert(Music.writeMetadata(mp3, {:artist => "Test", :year => 2019}))
		mp3new = Music.availableMetadata(mp3)
		assert_equal(2019, mp3new[:year])
		assert_equal("Test", mp3new[:artist])

		assert(Music.writeMetadata(mp3, {:artist => "Zammuto", :year => 2011}))
		
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

