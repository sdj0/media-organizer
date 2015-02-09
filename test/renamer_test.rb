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
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15:16:51 -0500.jpg")
		assert_equal(new_uris[old_uris[1]], "Test-2015-01-14 16:38:06 -0500.jpg")

	end

	def test_GenerateRenameList_GoodTIFFs
		old_uris = ['./test/data/hs-2003-24-a-full_tif.tif']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#puts "New URIS Hash: #{new_uris}"
		assert_equal(new_uris[old_uris[0]], "Test-2003-09-03 12:52:43 -0400.tif")

	end

	#Run rename list with scheme argument specified
	def test_GenerateRenameList_WithSchemeArg
		old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
		schemearr = ["Test-", :date_time]
		r = Renamer.new()

		new_uris = r.generateRenameList(old_uris, scheme: schemearr)
		#puts "New URIS Hash: #{new_uris}"
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15:16:51 -0500.jpg")
		assert_equal(new_uris[old_uris[1]], "Test-2015-01-14 16:38:06 -0500.jpg")

	end

	def test_Overwrite_GoodJPEGs
		old_uris = ['./test/data/pic1.jpg', './test/data/pic2.jpg']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

		new_uris = r.generateRenameList(old_uris)
		#r.overwrite(new_uris)
		#puts "New URIS Hash: #{new_uris}"
		#assert(File.exists("./test/data/Test-2015-01-14 15:16:51 -0500.jpg"))
		#assert(File.exists("./test/data/Test-2015-01-14 16:38:06 -0500.jpg"))

	end

	def test_Overwrite_GoodTIFFs

	end


###########Failure modes###########

	#Validate that invalid (and unsupported) file types are not renamed
	def test_GenerateRenameList_IgnoreInvalidURIs
		old_uris = ['./test/data/pic1.jpg','./test/data/bad_data/asdfasdfasdf.ghjk']
		scheme = ["Test-", :date_time]
		r = Renamer.new()
		r.setNamingScheme(scheme)

#		assert_raises (FileNotValidError) 
		new_uris = r.generateRenameList(old_uris)
		#Check that the valid file was added to the hash
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15:16:51 -0500.jpg")
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
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15:16:51 -0500.jpg")
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
		assert_equal(new_uris[old_uris[0]], "Test-2015-01-14 15:16:51 -0500.jpg")
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
		#uri_list2 = 25
		#assert_raises(InvalidArgumentError) {r.generateRenameList(uri_list2)}

		#Test nil argument
		#uri_list3 = nil
		#assert_raises(InvalidArgumentError) {r.generateRenameList(uri_list3)}


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


