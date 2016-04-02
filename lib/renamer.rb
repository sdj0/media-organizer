# renamer.rb: main codebase for the media-renamer gem.
# Currently configured to only rename JPG and TIF files (using EXIFR to extract metadata)
# next major release will include support
require 'scrapers/image.rb'
require 'scrapers/music.rb'
require 'fileutils'

module MediaOrganizer
  class FileNotValidError < StandardError; end
  class InvalidArgumentError < StandardError; end
  class UnsupportedFileTypeError < StandardError; end
  class RenameFailedError < StandardError; end
  class EmptyMetadataError < StandardError; end

  # Renamer: primary class to use for renaming files. Allows renaming of a given list of files to a user-defined scheme based on each file's metadata.
  #
  #===Key Methods
  # 	*naming_scheme()
  # 	*generate()
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
  #	r.set_naming_scheme(scheme)
  #
  #	new_uris = r.generate(old_uris)
  #
  #	r.overwrite(new_uris) #new filename: "./test/data/Test-2003-09-03 12_52_43 -0400.tif")
  #
  class Renamer
    DISALLOWED_CHARACTERS = /[\\:\?\*<>\|"\/]/	# Characters that are not allowed in file names by many file systems. Replaced with @subchar character.

    attr_reader	:naming_scheme	# Array of strings and literals used to construct filenames. Set thruough naming_scheme as opposed to typical/default accessor.
    attr_accessor	:subchar	# Character with which to substitute disallowed characters

    def initialize(_args = {})
      @naming_scheme = ['Renamed-default-']
      @subchar = '_'
    end

    # Renamer.naming_scheme(): sets the naming scheme for the generate method.
    #
    #===Inputs
    # 		1. Array containing strings and symbols.
    #
    #===Outputs
    # None (sets instance variable @naming_scheme)
    #
    #===Example
    # naming_scheme(["Vacation_Photos_", :date_taken]).
    # This will rename files into a format like "Vacation_Photos_2014_05_22.png" based on the file's date_taken metadata field.
    def set_naming_scheme(arr = [])
      @naming_scheme = set_scheme(arr)
    end

    # Renamer.generate(): Creates a hash mapping the original filenames to the new (renamed) filenames
    #
    #===Inputs
    # 		1. List of URIs in the form of an array
    # 		2. Optional hash of arguments.
    # 			*:scheme - array of strings and symbols specifying file naming convention
    #
    #===Outputs
    # Hash of "file name pairs." old_file => new_file
    def generate(uri_list = [], args = {})
      scheme = if !args[:scheme].nil? && args[:scheme].is_a?(Array) && !args[:scheme].empty?
                 set_scheme(args[:scheme])
               else
                 @naming_scheme
               end
      raise InvalidArgumentError unless !uri_list.nil? && uri_list.is_a?(Array)

      filename_pairs = {}
      uri_list.each do |i|
        new_string = handle_file(i, scheme)
        filename_pairs[i] = new_string if !new_string.nil? && new_string != ''
      end

      return filename_pairs

    rescue InvalidArgumentError => arg_e
      puts "#{arg_e}: Invalid arguments provided. Expected: uri_list = [], args = {}\n"
    rescue => e
      puts e.message
      puts e.backtrace.inspect
    end

    # Renamer.overwrite(): Writes new file names (in place) based upon mapping provided in the hash
    # argument. NOTE: this will alter the file system!
    #
    #===Inputs
    # 		1. Hash containing mappings between old filenames (full URI) and new filenames (full URI).
    # Example: {"/path/to/oldfile.jpg" => "/path/to/newfile.jpg"}
    #
    #===Outputs
    # none (file names are overwritten)
    def overwrite(renames_hash = {})
      renames_hash.each do |old_name, new_name|
        begin
          unless old_name.is_a?(String) && File.exist?(old_name)
            raise FileNotValidError, "Could not access specified source file: #{i}."
          end
          unless new_name.is_a?(String)
            raise FileNotValidError, 'New file name provided is not a string'
          end
          # TODO: Ignore dir names embedded in new_name
          path = File.dirname(File.absolute_path(old_name)) + '/'
          new_name = dedupe_file(path, new_name)
          File.rename(File.absolute_path(old_name), File.absolute_path(old_name) + '/' + new_name)
        rescue => e
          puts "#{e}: Ignoring rename for #{old_name} => #{new_name}\n"
        end
      end
    end

    # Renamer.backup(): Writes new file names into a specified backup directory,
    # based upon mapping provided in the hash argument. NOTE: this will alter the file system!
    #
    #===Inputs
    #     1. Hash containing mappings between old filenames (full URI) and new filenames (full URI).
    # Example: {"/path/to/oldfile.jpg" => "newfilename.jpg"}
    #     2. Top level URI where backup files will be written
    #
    #===Outputs and Postconditions
    # New files are created in the directory provided as the second argument
    def backup(renames_hash = {}, uri)
      unless !uri.nil? && uri.is_a?(String) && File.directory?(uri) && File.writable?(uri)
        raise StandardError, 'URI argument must be a string containing a valid and accesible'
      end
      uri = File.absolute_path(uri)

      renames_hash.each do |old_name, new_name|
        begin
          unless old_name.is_a?(String) && File.exist?(old_name)
            raise FileNotValidError, "Could not access specified source file: #{i}."
          end
          unless new_name.is_a?(String)
            raise FileNotValidError, 'New file name provided is not a string'
          end
          path = File.absolute_path(uri) + '/'
          new_name = dedupe_file(path, new_name)
          FileUtils.cp(File.absolute_path(old_name), path + new_name)
        rescue => e
          puts "#{e}: Ignoring rename for #{old_name} => #{new_name}\n"
        end
      end
    end

    # Routes metadata scrape based on file type (currently relies on extension - future version should use MIME)
    # currently assumes file was checked for validity in calling code.
    #
    #===Inputs
    # String containing full file URI (path and filename)
    #
    #===Outputs
    # Returns hash of metadata for file, or nil if none/error.
    def	get_metadata(file)
      # LOAD EXIF DATA
      case File.extname(file).downcase
      when '.jpg'
        Image.get_jpeg_data(file)
      when '.tif'
        Image.get_tiff_data(file)
      when '.mp3', '.wav', '.flac', '.aiff', '.ogg', '.m4a', '.asf'
        Music.get_music_data(file)
      else
        raise UnsupportedFileTypeError, "Could not process file: Extension #{File.extname(file)} is not supported."
      end
    end

    private

    def handle_file(file, scheme)
      scheme ||= @naming_scheme
      unless file.is_a?(String) && File.exist?(file)
        raise FileNotValidError, "Could not access specified file: #{file}."
      end
      new_filename = schemify(file, scheme)
      return new_filename + File.extname(file)

    rescue FileNotValidError, UnsupportedFileTypeError => file_e
      puts "#{file_e}: #{file_e.message}\n"
      return nil
    rescue => e
      puts e.message
      puts e.backtrace.inspect
      return nil
    end

    def schemify(file, scheme)
      schemed_file = ''
      metadata = get_metadata(File.absolute_path(file))
      scheme.each do |j|
        schemed_file += get_from_meta(metadata, j)
      end
      schemed_file
    end

    def get_from_meta(metadata, j)
      if j.is_a?(String)
        return sub_hazardous_chars(j)
      elsif j.is_a?(Hash)
        #TODO: Add directory handling here
      elsif j.is_a?(Symbol)
        if metadata[j].is_a?(String) || metadata[j].respond_to?(:to_s)
          return sub_hazardous_chars(metadata[j].to_s)
        else
          puts "Warning: could not get string for metadata tag provided in scheme: #{j}.\n"
          return sub_hazardous_chars("Unknown #{j.to_s.capitalize}")
        end
      end
    end

    def set_scheme(input_arr = [])
      clean_scheme = []
      input_arr.each do |i|
        clean_scheme << i if i.is_a?(String) || i.is_a?(Symbol)
      end
      clean_scheme
    end

    def sub_hazardous_chars(str = '')
      str.gsub(DISALLOWED_CHARACTERS, @subchar)
    end

    def dedupe_file(path, new_name)
      path += '/' unless !path.nil? && path[-1, 1] == '/'
      i = 0
      test_name = new_name
      while File.exist?(path + test_name)
        test_name = new_name.sub(/.[^.]+\z/, '') + " (#{i += 1})" + File.extname(new_name)
      end
      test_name
    end
  end
end
