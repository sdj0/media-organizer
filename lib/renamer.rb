#renamer.rb: main codebase for the media-renamer gem. 
#Currently configured to only rename JPG and TIF files (using EXIFR to extract metadata)
	#next major release will include support 


require 'scrapers/image.rb'
require 'scrapers/music.rb'

class FileNotValidError < StandardError ; end
class InvalidArgumentError < StandardError ; end
class UnsupportedFileTypeError < StandardError ; end
class RenameFailedError < StandardError ; end


class Renamer
	include Image
	include Music
	attr_accessor	:naming_scheme 	# => array of strings and literals used to construct filenames

	def initialize
		@naming_scheme = ["Renamed-default-"]
	end

	def setNamingScheme(arr = [])
		@naming_scheme = setScheme(arr)
	end
	#Input: list of URIs in the form of an array
	#Output: hash of "file name pairs." old_file => new_file
	#Accepts optional arguments: :scheme (array of strings and symbols specifying file naming convention)
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
	#currently assumes file was checked for validity in calling code
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
		#otherwise, outsource
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
		return new_string + File.extname(file)	
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
end




