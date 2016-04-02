# Test file for the Filescanner class

require 'minitest'
require 'filescanner'

class TestFilescanner < MiniTest::Test
  def test_dir_valid_tree
    f = MediaOrganizer::Filescanner.new
    arr = f.open('./test/data/filescan_top')
    assert_equal(7 + 5, arr.size, 'Mismatch in number of files returned by Filescanner')
    assert(arr.include?('./test/data/filescan_top/track_root.mp3'))
    assert(arr.include?('./test/data/filescan_top/image_root.jpg'))
    assert(arr.include?('./test/data/filescan_top/goodmusic/fakeaiff.aiff'))
    assert(arr.include?('./test/data/filescan_top/goodmusic/subdir1/Tori Amos - 12 - Little Earthquakes.m4a'))

    # check that non-media files are ignored
    assert(!arr.include?('./test/data/filescan_top/goodmusic/nonmusic.txt'))
    assert(!arr.include?('./test/data/filescan_top/nonmedia/asdf.txt'))
    assert(!arr.include?('./test/data/filescan_top/empty.nothing'))
  end

  def test_dir_valid_single
    f = MediaOrganizer::Filescanner.new
    arr = f.open('./test/data/filescan_top', mode: :single)
    assert_equal(2, arr.size, 'Mismatch in number of files returned by Filescanner')
    assert(arr.include?('./test/data/filescan_top/track_root.mp3'))
    assert(arr.include?('./test/data/filescan_top/image_root.jpg'))
    # check that non-media files are ignored
    assert(!arr.include?('./test/data/filescan_top/empty.nothing'))
  end

  def test_dir_valid_musiconly
    f = MediaOrganizer::Filescanner.new
    arr = f.open('./test/data/filescan_top', image: false)
    assert_equal(7, arr.size, 'Mismatch in number of files returned by Filescanner')
    assert(arr.include?('./test/data/filescan_top/track_root.mp3'))
    assert(!arr.include?('./test/data/filescan_top/image_root.jpg'))
  end

  def test_dir_valid_imageonly
    f = MediaOrganizer::Filescanner.new
    arr = f.open('./test/data/filescan_top', music: false)
    assert_equal(5, arr.size, 'Mismatch in number of files returned by Filescanner')
    assert(!arr.include?('./test/data/filescan_top/track_root.mp3'))
    assert(arr.include?('./test/data/filescan_top/image_root.jpg'))
  end

  def test_dir_nonmedia
    f = MediaOrganizer::Filescanner.new
    arr = f.open('./test/data/filescan_top/nonmedia')
    assert_equal(0, arr.size, 'Mismatch in number of files returned by Filescanner')
    assert(!arr.include?('./test/data/filescan_top/nonmedia/temp_csv.csv'))
  end

  def test_dir_invalid
    f = MediaOrganizer::Filescanner.new
    assert(f.open('./24u89gihrjnkf/nonexistantdir') == false)
  end

  def test_add_root_multiscan_mode
  end

  def test_add_root_multiscan_mode_withargs
  end
end
