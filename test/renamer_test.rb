gem "minitest"

require 'minitest/autorun'
require 'renamer'

class TestRenamer < MiniTest::Unit::TestCase

	def test_SetNamingScheme
		r = Renamer.new()
		scheme = ["Test-"]
		r.setNamingScheme(scheme)
		assert_equal(scheme, r.naming_scheme)
	end

	def test_GenerateRenameList_GoodJPEGs
		old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#puts "New URIS Hash: #{new_uris}"
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15_16_51 -0500.jpg")
		assert_equal(new_uris[old_uris[1]], "Test-2015-01-14 16_38_06 -0500.jpg")

	end

	def test_GenerateRenameList_GoodTIFFs
		old_uris = ['./test/data/hs-2003-24-a-full_tif.tif']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#puts "New URIS Hash: #{new_uris}"
		assert_equal(new_uris[old_uris[0]], "Test-2003-09-03 12_52_43 -0400.tif")

	end

	#Expect success on each of 3 music files tested. Currently tests for m4a, flac, and mp3
	def test_GenerateRenameList_GoodMusicFiles
		old_uris = ['./test/data/Tori Amos - 12 - Little Earthquakes.m4a', './test/data/Too Late to Topologize.mp3', './test/data/cj2009-10-05d01t10.ku100_at37.flac']
		scheme = ["Test__", :artist, "-", :title]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		puts "New URIS Hash: #{new_uris}"
		assert_equal("Test__Tori Amos-Little Earthquakes.m4a", new_uris[old_uris[0]])
		assert_equal("Test__Zammuto-Too Late To Topologize.mp3", new_uris[old_uris[1]])		
		assert_equal("Test__Cowboy Junkies-Moonlight Mile (FOH Gain Shift at 3_14) [Engineered For Headphone Use].flac", new_uris[old_uris[2]])		
	end


	#Run rename list with scheme argument specified
	def test_GenerateRenameList_WithSchemeArg
		old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
		schemearr = ["Test-", :date_time]
		r = Renamer.new()

		new_uris = r.generateRenameList(old_uris, scheme: schemearr)
		#puts "New URIS Hash: #{new_uris}"
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15_16_51 -0500.jpg")
		assert_equal(new_uris[old_uris[1]], "Test-2015-01-14 16_38_06 -0500.jpg")

	end

	def test_generateRenameList_hazardous_JPEG
		old_uris = ['./test/data/pic1.jpg']
		scheme = ["haz?ardz |n >< here___", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#puts "New URIS Hash: #{new_uris}"
		assert_equal(new_uris[old_uris[0]], "haz_ardz _n __ here___2015-01-14 15_16_51 -0500.jpg")
	end

	def test_generateRenameList_reset_subchar
		old_uris = ['./test/data/pic1.jpg']
		scheme = ["haz?ardz |n >< here___", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		r.subchar = "."
		new_uris = r.generateRenameList(old_uris)
		#puts "New URIS Hash: #{new_uris}"
		assert_equal(new_uris[old_uris[0]], "haz.ardz .n .. here___2015-01-14 15.16.51 -0500.jpg")
	end

	#Test passes as of v0.0.1. Removed from scenario due to filename changes (and need for subsequent reset)
	def test_Overwrite_GoodJPEGs
		old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#r.overwrite(new_uris)
		#puts "New URIS Hash: #{new_uris}"
		#assert(File.exists("./test/data/Test-2015-01-14 15_16_51 -0500.jpg"))
		#assert(File.exists("./test/data/Test-2015-01-14 16_38_06 -0500.jpg"))

	end

	def test_Overwrite_GoodTIFFs
		#TBC
	end

	def test_Overwrite_GoodMP3s
		old_uris = ['./test/data/Too Late to Topologize.mp3']
		scheme = ["Test__", :artist, "-", :title]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#r.overwrite(new_uris)
		#puts "New URIS Hash: #{new_uris}"
		#assert(File.exists?("./test/data/Test__Zammuto-Too Late To Topologize.mp3"))
		#if File.exists?("./test/data/Test__Zammuto-Too Late To Topologize.mp3")
		#	File.rename("./test/data/Test__Zammuto-Too Late To Topologize.mp3", './test/data/Too Late to Topologize.mp3')
		#end


	end

	def test_write_music_metadata
		flac = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Denali - The Instinct - 05 - Do Something.flac"
		mp3 = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Too Late to Topologize.mp3"
		wav = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/09-Infinity.wav"
		m4a = "/mnt/hgfs/Repositories/media-organizer/test/data/meta_overwrite/Tori Amos - 12 - Little Earthquakes.m4a"



	end


###########Failure modes###########

	#Validate that invalid (and unsupported) file types are not renamed
	def test_GenerateRenameList_IgnoreInvalidURIs
		old_uris = ['./test/data/pic1.jpg','./test/data/bad_data/asdfasdfasdf.ghjk']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#Check that the valid file was added to the hash
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15_16_51 -0500.jpg")
		#Check that the invalid file was not added to the array (i.e. only the valid file exists in response)
		assert(new_uris.size == 1)
	end

	def test_GenerateRenameList_IgnoreInvalidFiletypes
		old_uris = ['./test/data/pic1.jpg','./test/data/bad_data/taglib-1.8.tar.gz']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#Check that the valid file was added to the hash
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15_16_51 -0500.jpg")
		#Check that the invalid file was not added to the array (i.e. only the valid file exists in response)
		assert(new_uris.size == 1)

	end

	def test_GenerateRenameList_MissingMetadata
		old_uris = ['./test/data/pic1.jpg','./test/data/bad_data/pic1_nometadata_comment.jpg']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#Check that the valid file was added to the hash
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15_16_51 -0500.jpg")
		#Check that the invalid file was not added to the array (i.e. only the valid file exists in response)
		assert_equal(new_uris.size, 1)
	end

	def test_GenerateRenameList_EmptyOrInvalidList
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		#Test empy URI list. Should return empty hash
		uri_list1 = []
		new_uris1 = r.generateRenameList(uri_list1)
		assert_equal(new_uris1, {})

		#Test invalid argument type. Should be ignored and return empty hash.
		uri_list2 = 25
		new_uris2 = r.generateRenameList(uri_list2)
		assert_equal(new_uris2, nil)

		#Test nil argument
		uri_list3 = nil
		new_uris3 = r.generateRenameList(uri_list3)
		assert_equal(new_uris3, nil)

	end

	def test_GenerateRenamelist_InvalidSchemeElements
		r = Renamer.new()
		bad_arr = ['bad']
		bad_hash = {'bad' => 'not good'}
		full_scheme = ["Test-", :asdf, 25, bad_arr, bad_hash]

		#Expect that symbols and strings are processed, other are ignore
		expected_arr = ["Test-", :asdf]
		r.setNamingScheme(full_scheme)
		assert_equal(expected_arr, r.naming_scheme)
	end



end


