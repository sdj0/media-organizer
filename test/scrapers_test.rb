gem 'minitest'

require 'minitest/autorun'
require './lib/scrapers/image.rb'
require './lib/scrapers/music.rb'

class TestMusic < MiniTest::Test
  # music scraper tests
  def test_ismusic_validfile_supported
    assert(MediaOrganizer::Music.music?('./test/data/Too Late to Topologize.mp3'))
  end

  def test_ismusic_validfile_unsupported
    assert(!MediaOrganizer::Music.music?('./test/data/pic2.jpg'))
  end

  def test_ismusic_invalidfile
    assert_raises (StandardError) { MediaOrganizer::Music.music?('./test/data/macabre_kebab_asdfasdf') }
  end

  def test_music_available_metadata
    mp3 = './test/data/meta_overwrite/Too Late to Topologize.mp3'
    m4a = './test/data/meta_overwrite/Tori Amos - 12 - Little Earthquakes.m4a'
    # flac = "./test/data/meta_overwrite/Denali - The Instinct - 05 - Do Something.flac"
    # wav = './test/data/meta_overwrite/09-Infinity.wav'

    mp3meta = MediaOrganizer::Music.availableMetadata(mp3)
    assert_equal('Zammuto', mp3meta[:artist])
    m4ameta = MediaOrganizer::Music.availableMetadata(m4a)
    assert_equal('Tori Amos', m4ameta[:artist])
    # flacmeta = MediaOrganizer::Music.availableMetadata(flac)
    # assert_equal("Denali", flacmeta[:artist])
    # wavmeta = MediaOrganizer::Music.availableMetadata(wav)
    # assert_equal('The xx', wavmeta[:artist])
  end

  def test_music_write_metadata
    mp3 = './test/data/meta_overwrite/Too Late to Topologize.mp3'
    m4a = './test/data/meta_overwrite/Tori Amos - 12 - Little Earthquakes.m4a'

    assert(MediaOrganizer::Music.writeMetadata(mp3, artist: 'Test', year: 2019))
    mp3new = MediaOrganizer::Music.availableMetadata(mp3)
    assert_equal(2019, mp3new[:year])
    assert_equal('Test', mp3new[:artist])

    assert(MediaOrganizer::Music.writeMetadata(mp3, artist: 'Zammuto', year: 2011))
  end
end

class TestImage < MiniTest::Test
  # image scraper tests

  def test_isimage_validfile_supported
    assert_equal(true, MediaOrganizer::Image.image?('./test/data/pic2.jpg'))
  end

  def test_isimage_validfile_unsupported
    assert_equal(false, MediaOrganizer::Image.image?('./test/data/Too Late to Topologize.mp3'))
  end

  def test_isimage_invalidfile
    assert_raises(StandardError) { test = MediaOrganizer::Image.image?('./test/data/macabre_kebab_asdfasdf') }
  end
end
