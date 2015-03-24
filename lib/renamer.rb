#renamer.rb: main codebase for the media-renamer gem. 
#Currently configured to only rename JPG and TIF files (using EXIFR to extract metadata)
	#next major release will include support 
require 'scrapers/image.rb'
require 'scrapers/music.rb'

module MediaOrganizer

	class FileNotValidError < StandardError ; end
	class InvalidArgumentError < StandardError ; end
	class UnsupportedFileTypeError < StandardError ; end
	class RenameFailedError < StandardError ; end
	
	#Renamer: primary class to use for renaming files. Allows renaming of a given list of files to a user-defined scheme based on each file's metadata.
	#
	#===Key Methods
	# 	*setNamingScheme()
	# 	*generateRenameList()
	# 	*overwrite()
	#
	#===Example Usage
	#
	#	old_uris = ['./test/data/hs-2003-24-a-full_tif.tif']
	#
	#	scheme = ["Test-", :date_time]
	#
	#	r = Renamer.new()
	#
	#	r.setNamingScheme(scheme)
	#
	#	new_uris = r.generateRenameList(old_uris)
	#
	#	r.overwrite(new_uris) #new filename: "./test/data/Test-2003-09-03 12_52_43 -0400.tif")
	#
	class Renamer
		DISALLOWED_CHARACTERS = /[\\:\?\*<>\|"\/]/ 	#Characters that are not allowed in file names by many file systems. Replaced with @subchar character.

		attr_accessor	:naming_scheme 	#Array of strings and literals used to construct filenames. Set thruough setNamingScheme as opposed to typical/default accessor.
		attr_accessor 	:subchar 		#Character with which to substitute disallowed characters

		def initialize(args = {})
			@naming_scheme = ["Renamed-default-"]
			@subchar = "_"
		end

		#Renamer.setNamingScheme(): sets the naming scheme for the generateRenameList method. 
		#
		#===Inputs
		# 		1. Array containing strings and symbols.
		#
		#===Outputs
		#None (sets instance variable @naming_scheme)
		#
		#===Example
		#setNamingScheme(["Vacation_Photos_", :date_taken]). 
		#This will rename files into a format like "Vacation_Photos_2014_05_22.png" based on the file's date_taken metadata field.
		def setNamingScheme(arr = [])
			@naming_scheme = setScheme(arr)
		end

		#Renamer.generateRenameList(): Creates a hash mapping the original filenames to the new (renamed) filenames
		#
		#===Inputs
		# 		1. List of URIs in the form of an array
		# 		2. Optional hash of arguments.
		# 			*:scheme - array of strings and symbols specifying file naming convention
		#
		#===Outputs
		#Hash of "file name pairs." old_file => new_file
		def generateRenameList(uri_list = [], args = {})
			if args[:scheme] != nil && args[:scheme].is_a?(Array) && !args[:scheme].empty?
				scheme = setScheme(args[:scheme])
			else
				scheme = @naming_scheme
			end
			unless !uri_list.nil? && uri_list.is_a?(Array) 
				raise InvalidArgumentError
			end

			filename_pairs = {}
			uri_list.each do |i|
				new_string = handleFile(i, scheme)
				#If this is a valid file path, add it to the filename_pairs
				#puts "New file rename added: #{new_string}"
				if new_string != nil && new_string != ""
					filename_pairs[i] = new_string
				end
			end

			return filename_pairs
		
		rescue InvalidArgumentError => arg_e
			puts arg_e
			puts "Invalid arguments provided. Expected: uri_list = [], args = {}"
			puts arg_e.backtrace.inspect
		rescue => e
			puts e 
			puts e.message 
			puts e.backtrace.inspect
		end

		#Renamer.overwrite(): Writes new file names based upon mapping provided in hash argument. NOTE: this will create changes to file names!
		#
		#===Inputs 
		# 		1. Hash containing mappings between old filenames (full URI) and new filenames (full URI). Example: {"/path/to/oldfile.jpg" => "/path/to/newfile.jpg"}
		#
		#===Outputs 
		#none (file names are overwritten)
		def overwrite(renames_hash = {})
			renames_hash.each do |old_name, new_name|
				begin
					#error/integrity checking on old_name and new_name
		  			raise FileNotValidError, "Could not access specified source file: #{i}." unless old_name.is_a?(String) && File.exists?(old_name)    
		    		raise FileNotValidError, "New file name provided is not a string" unless new_name.is_a?(String)
		    		
		    		#puts (File.dirname(File.absolute_path(old_name)) + "/" + new_name) #Comment this line out unless testing
		    		File.rename(File.absolute_path(old_name),File.dirname(File.absolute_path(old_name)) + "/" + new_name)
									
					#check that renamed file exists - Commented out because this currently does not work.
					#unless new_name.is_a?(String) && File.exists?(new_name)    
		      		#	raise RenameFailedError, "Could not successfuly rename file: #{old_name} => #{new_name}. Invalid URI or file does not exist."
		    		#end
		    	rescue => e
		    		puts "Ignoring rename for #{old_name} => #{new_name}"
		    		puts e
		    		puts e.backtrace.inspect
				end
			end
		end

		#Routes metadata scrape based on file type (currently relies on extension - future version should use MIME)
		#currently assumes file was checked for validity in calling code.
		#
		#===Inputs 
		#String containing full file URI (path and filename) 
		#
		#===Outputs 
		#Returns hash of metadata for file, or nil if none/error.
		def	getFileMetadata(file)
			
			#LOAD EXIF DATA	
			case File.extname(file).downcase
			when '.jpg'
				Image::getJpegData(file)
			when '.tif'
				Image::getTiffData(file)
			when '.mp3' , '.wav' , '.flac' , '.aiff', '.ogg', '.m4a', '.asf'
				Music::getMusicData(file)
			else
				raise UnsupportedFileTypeError, "Error processing #{file}"
			end
		rescue UnsupportedFileTypeError => e
			puts "Could not process file: Extension #{File.extname(file)} is not supported."
			puts e.backtrace.inspect
		end


		private
		def handleFile(file, scheme)
				#Check file is real
		    unless file.is_a?(String) && File.exists?(file) 
	  			raise FileNotValidError, "Could not access specified file file: #{file}."
			end
			#convert URI (i) to absolute path

			#get metadata hash for this file (i)
			metadata = getFileMetadata(File.absolute_path(file))
			#build URI string
			new_string = ""
			scheme.each do |j|
				if j.is_a?(String) then new_string += j
				elsif j.is_a?(Symbol) 
					begin
						raise EmptyMetadataError unless metadata[j] != nil
						new_string += metadata[j].to_s
					rescue => e 
						puts "Could not get string for metadata tag provided in scheme: #{j} for file #{file}." 
						puts "Ignoring file #{file}"
						puts e.backtrace.inspect
						return nil
					end
				end
			end
			#puts "Found file metadata: #{metadata[:date_time]}"
			return subHazardousChars(new_string + File.extname(file))
		rescue FileNotValidError => e
			puts ("Ignoring file #{file}")
			puts e 
			puts e.backtrace
			return nil
		rescue => e
			puts e.message
			puts e.backtrace.inspect
			return nil
		end

		def setScheme(input_arr = [])
			clean_scheme = []
			input_arr.each do |i|
				if i.is_a?(String) || i.is_a?(Symbol)
					clean_scheme << i
				end
			end
			return clean_scheme
		end

		def subHazardousChars(str = "")
			return str.gsub(DISALLOWED_CHARACTERS, @subchar)
		end
	end

end
