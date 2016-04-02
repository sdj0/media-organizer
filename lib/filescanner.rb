#
# The Filescanner class scans directory trees for
# media files. The key API method for Filescaner is #open(String, Hash) which
# loads each supported file from a directory tree into an array.
#

require 'scrapers/image.rb'
require 'scrapers/music.rb'

module MediaOrganizer
  class Filescanner
    include Image
    include Music

    attr_reader :root_nodes
    attr_accessor :source_list

    def initialize
      @root_nodes = []
      @source_list = []
    end

    #
    # Filescanner.open(String, {}): scans directory tree for media files,
    # starting at String specified in first argument.
    #
    #==Inputs
    #===Required
    # (1) String: String containing the URI of the top of the directory tree to scan
    #
    #===Optional
    # (2) Arguments Hash:
    # *:mode => (:single) -- if set to :single, only the given URI will be scanned.
    # Subdirectories will be ignored.
    # *:music => (true, false) -- if true, music files will be included in the scan.
    #  Set to false to exclude music files. Defaults to true
    # *:image => (true, false) -- if true, image files will be included in the scan.
    #  Set to false to exclude image files. Defaults to true
    #
    #==Outputs
    # Returns array of strings, where each string is a file URI for a music or image file.
    # Invalid files and directories will be ignored (i.e. will not be included in
    # the returned array)
    #
    #
    #==Usage Example
    # filescanner = MediaOrganizer::Filescanner.new
    # filescanner.open("/absolute/path/for/top/of/directory/tree")
    #
    def open(uri = '', args = {})
      @source_list = []
      include_images = true unless args[:image] == false
      include_music = true unless args[:music] == false

      files = load_files(uri, args[:mode])
      files.each do |f|
        if (Music.music?(f) && include_music) || (Image.image?(f) && include_images)
          @source_list << f
        end
      end

      return @source_list

    rescue StandardError => e
      puts "Warning: #{e.message}"
      return false
    end

    # alternative run mode. Add multiple "root" directories to scan at once
    def add_root(dir_uri)
      validate_uri(dir_uri)
      @root_nodes << dir_uri
    rescue StandardError => e
      puts "Warning: #{e.message}"
      return false
    end

    # <<(): synonym for add_root(). Also a deformed emoticon.
    #  def << (dir_uri) add_root(dir_uri)  end

    #
    # multiscan(): scans multiple directories added to @root_nodes using the add_root() method.
    #
    #==Inputs
    #===Required
    # none
    #
    #===Optional
    # (1) Arguments Hash:
    # *:mode => (:single, :multiple)
    # *:music => (true, false) -- if true, music files will be included in the scan.
    #  Set to false to exclude music files. Defaults to true
    # *:image => (true, false) -- if true, image files will be included in the scan.
    #  Set to false to exclude image files. Defaults to true
    #
    #==Outputs
    # Array of strings, where each string is a file URI for a music or image file.
    #
    def multiscan(args = {})
      @root_nodes.each do |uri|
        open(uri, args)
      end
      @source_list
    end

    private

    # validate_uri(): support method for validating a file system URI.
    #
    #==Inputs
    #===Required
    # (1) String: String containing the URI to validate.
    #
    #===Optional
    # none
    #==Outputs
    # Returns true if the URI is valid. Raises a StandardError exception if it is not.
    #
    def validate_uri(uri)
      unless !uri.nil? && uri.is_a?(String) && (File.directory?(uri) || File.exist?(uri))
        raise StandardError, "Directory given (#{uri}) could not be accessed."
      end
      true
    end

    #
    # load_files(): given a URI and optional mode, scans and loads every file in
    # the specifid folder or tree.
    #
    #==Inputs
    #===Required
    # (1) String: String containing the URI to validate.
    #
    #===Optional
    # (1) Arguments Hash:
    # *:mode => (:single, :multiple) - :single loads a folder, :multiple loads a full tree.
    #
    #==Outputs
    # Array of strings, where each string is a file URI for a music or image file.
    #
    def load_files(uri, mode)
      validate_uri(uri)
      if !mode.nil? && mode == :single
        Dir.glob("#{uri}/*")
      else
        Dir.glob("#{uri}/**/*")
      end
    end
  end
end
