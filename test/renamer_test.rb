gem 'minitest'

require 'minitest/autorun'
require 'renamer'

class TestRenamer < MiniTest::Unit::TestCase
  def test_naming_scheme
    r = MediaOrganizer::Renamer.new
    scheme = ['Test-']
    r.set_naming_scheme(scheme)
    assert_equal(scheme, r.naming_scheme)
  end

  def test_generate_good_jpegs
    old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
    scheme = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    assert(new_uris[old_uris[0]] =~ /\ATest-2015-01-14 15_16_51 [+-][0-9]{4}.jpg/)
    assert(new_uris[old_uris[1]] =~ /\ATest-2015-01-14 16_38_06 [+-][0-9]{4}.jpg/)
  end

  def test_generate_good_tiffs
    old_uris = ['./test/data/gebco_08_rev_elev_A2_grey_geo.tif']
    scheme = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    assert(new_uris[old_uris[0]] =~ /\ATest-2014-01-28 18_14_08 [+-][0-9]{4}.tif/)
  end

  # Expect success on each of 3 music files tested. Currently tests for m4a, flac, and mp3
  def test_generate_good_music_files
    old_uris = ['./test/data/Tori Amos - 12 - Little Earthquakes.m4a', './test/data/Too Late to Topologize.mp3', './test/data/cj2009-10-05d01t10.ku100_at37.flac']
    scheme = ['Test__', :artist, '-', :title]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    assert_equal('Test__Tori Amos-Little Earthquakes.m4a', new_uris[old_uris[0]])
    assert_equal('Test__Zammuto-Too Late To Topologize.mp3', new_uris[old_uris[1]])
    assert_equal('Test__Cowboy Junkies-Moonlight Mile (FOH Gain Shift at 3_14) [Engineered For Headphone Use].flac', new_uris[old_uris[2]])
  end

  # Run rename list with scheme argument specified
  def test_generate_with_schema_arg
    old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
    schemearr = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new

    new_uris = r.generate(old_uris, scheme: schemearr)
    # puts "New URIS Hash: #{new_uris}"
    assert(new_uris[old_uris[0]] =~ /\ATest-2015-01-14 15_16_51 [+-][0-9]{4}.jpg/)
    assert(new_uris[old_uris[1]] =~ /\ATest-2015-01-14 16_38_06 [+-][0-9]{4}.jpg/)
  end

  def test_generate_hazardous_jpeg
    old_uris = ['./test/data/pic1.jpg']
    scheme = ['haz?ardz |n >< here___', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    # puts "New URIS Hash: #{new_uris}"
    assert(new_uris[old_uris[0]] =~ /\Ahaz_ardz _n __ here___2015-01-14 15_16_51 [+-][0-9]{4}.jpg/,
           "Output mismatch: #{new_uris[old_uris[0]]}")
  end

  def test_generate_reset_subchar
    old_uris = ['./test/data/pic1.jpg']
    scheme = ['haz?ardz |n >< here___', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    r.subchar = '-'
    new_uris = r.generate(old_uris)
    # puts "New URIS Hash: #{new_uris}"
    assert(new_uris[old_uris[0]] =~ /\Ahaz-ardz -n -- here___2015-01-14 15-16-51 [+-][0-9]{4}.jpg/,
           "Output mismatch: #{new_uris[old_uris[0]]}")
  end

  # Test passes as of v0.0.1. Removed from scenario due to filename changes (and need for subsequent reset)
  def test_overwrite_good_jpegs
    old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
    scheme = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    # r.overwrite(new_uris)
    # puts "New URIS Hash: #{new_uris}"
    # assert(File.exist?("./test/data/Test-2015-01-14 15_16_51 -0500.jpg"))
    # assert(File.exist?("./test/data/Test-2015-01-14 16_38_06 -0500.jpg"))
  end

  def test_overwrite_good_tiffs
    # TBC
  end

  def test_overwrite_good_mp3s
    old_uris = ['./test/data/Too Late to Topologize.mp3']
    scheme = ['Test__', :artist, '-', :title]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    # r.overwrite(new_uris)
    # puts "New URIS Hash: #{new_uris}"
    # assert(File.exist?("./test/data/Test__Zammuto-Too Late To Topologize.mp3"))
    # if File.exist?("./test/data/Test__Zammuto-Too Late To Topologize.mp3")
    #	File.rename("./test/data/Test__Zammuto-Too Late To Topologize.mp3", './test/data/Too Late to Topologize.mp3')
    # end
  end

  def test_backup_good_mp3s_with_collision_avoidance
    #fs = MediaOrganizer::Filescanner.new
    #r = MediaOrganizer::Renamer.new

    # r.set_naming_scheme(['BAK - ', :artist, " - ", :title])
    # songs_to_backup = r.generate(fs.open('./test/data/backup/backup_src'))
    # r.backup(songs_to_backup, './test/data/backup/backup_dest')

    # assert(File.exist?('./test/data/backup/backup_dest/BAK -  -  (8).mp3'))
    # assert(File.exist?('./test/data/backup/backup_dest/BAK - Battles - Atlas.mp3'))
  end

  def test_unknown_artist_and_title_labeling
    # TODO: complete the code to make these tests work
    nameless_songs = ['./test/data/no_tags/1455.mp3', './test/data/no_tags/4160.mp3']
    meta = MediaOrganizer::Music.available_metadata(nameless_songs[0])

    assert(!meta.key?(:artist))
    assert(!meta.key?(:title))

    # r = MediaOrganizer::Renamer.new
    # r.overwrite(r.generate(nameless_song))
    # assert(File.exist?('./test/data/no_tags/Unknown Artist - Unknown Title.mp3'))
    # assert(File.exist?('./test/data/no_tags/Unknown Artist - Unknown Title (2).mp3'))
  end

  def test_generate_directory_structure
    songs = []
    f = MediaOrganizer::Filescanner.new
    r = MediaOrganizer::Renamer.new(naming_scheme: [{ directory: :artist }, { directory: :album }, :title])
    uris = r.generate(songs)

    # assert(File.directory?("./"))
    # assert(File.directory?("./"))
    # assert(File.directory?("./"))
  end

  # ##########Failure modes###########

  # Validate that invalid (and unsupported) file types are not renamed
  def test_generate_ingore_invalid_uris
    old_uris = ['./test/data/pic1.jpg', './test/data/bad_data/asdfasdfasdf.ghjk']
    scheme = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    # Check that the valid file was added to the hash
    assert(new_uris[old_uris[0]] =~ /\ATest-2015-01-14 15_16_51 [+-][0-9]{4}.jpg/)
    # Check that the invalid file was not added to the array (i.e. only the valid File.exist? in response)
    assert(new_uris.size == 1)
  end

  def test_generate_ignore_invalid_file_types
    old_uris = ['./test/data/pic1.jpg', './test/data/bad_data/taglib-1.8.tar.gz']
    scheme = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    # Check that the valid file was added to the hash
    assert(new_uris[old_uris[0]] =~ /\ATest-2015-01-14 15_16_51 [+-][0-9]{4}.jpg/)
    # Check that the invalid file was not added to the array (i.e. only the valid File.exist? in response)
    assert(new_uris.size == 1)
  end

  def test_generate_missing_metadata
    old_uris = ['./test/data/pic1.jpg', './test/data/bad_data/pic1_nometadata_comment.jpg']
    scheme = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    new_uris = r.generate(old_uris)
    # Check that the valid file was added to the hash
    assert(new_uris[old_uris[0]] =~ /\ATest-2015-01-14 15_16_51 [+-][0-9]{4}.jpg/)
    # Check that the invalid file was not added to the array (i.e. only the valid File.exist? in response)
    assert_equal(new_uris.size, 1)
  end

  def test_generate_empty_or_invalid_list
    scheme = ['Test-', :date_time]
    r = MediaOrganizer::Renamer.new
    r.set_naming_scheme(scheme)

    # Test empy URI list. Should return empty hash
    uri_list1 = []
    new_uris1 = r.generate(uri_list1)
    assert_equal(new_uris1, {})

    # Test invalid argument type. Should be ignored and return empty hash.
    uri_list2 = 25
    new_uris2 = r.generate(uri_list2)
    assert_equal(new_uris2, nil)

    # Test nil argument
    uri_list3 = nil
    new_uris3 = r.generate(uri_list3)
    assert_equal(new_uris3, nil)
  end

  def test_generate_invalid_scheme_elements
    r = MediaOrganizer::Renamer.new
    bad_arr = ['bad']
    bad_hash = { 'bad' => 'not good' }
    full_scheme = ['Test-', :asdf, 25, bad_arr, bad_hash]

    # Expect that symbols and strings are processed, other are ignore
    expected_arr = ['Test-', :asdf]
    r.set_naming_scheme(full_scheme)
    assert_equal(expected_arr, r.naming_scheme)
  end

  def test_backup_invalid_uris
    r = MediaOrganizer::Renamer.new
    assert_raises(StandardError) { r.backup({ 'shouldnt' => 'matter' }, './nonexistantdirectory') }
    assert_raises(StandardError) { r.backup({ 'shouldnt' => 'matter' }, './test/data/protected_directory') }
    assert_raises(StandardError) { r.backup({ 'shouldnt' => 'matter' }, nil) }
  end

  # ##########Support Methods###########

  private

  def cleanup_directory_tree(dir)
    #empty backup_dest folder
    #empty 
  end
end
