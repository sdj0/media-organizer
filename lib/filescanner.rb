#
#filescanner.rb: defines the class Filescanner, which scans directory trees for media files
#

require 'scrapers/image.rb'
require 'scrapers/music.rb'

class FileNotValidError < StandardError ; end

class Filescanner
  include Image
  include Music

  attr_reader :root_nodes
  attr_accessor :source_list


  def initialize()
    @root_nodes = []
    @source_list = []
  end

  #
  #Filescanner.open(String, {}): scans directory tree for media files, starting at String specified in first argument.
  #
  #==Inputs
  #===Required
  #(1) String: String containing the URI of the top of the directory tree to scan
  #
  #===Optional
  #(2) Arguments Hash:
  #*:mode => (:single) -- if set to :single, only the given URI will be scanned. Subdirectories will be ignored. 
  #*:music => (true, false) -- if true, music files will be included in the scan. Set to false to exclude music files. Defaults to true
  #*:image => (true, false) -- if true, image files will be included in the scan. Set to false to exclude image files. Defaults to true
  #
  #==Outputs
  #Returns array of strings, where each string is a file URI for a music or image file. 
  #
  #
  #==Usage Example
  #Filescanner.open("/absolute/path/for/top/of/directory/tree")
  #
  def open(uri = "", args = {})
    unless !uri.nil? && uri.is_a?(String) && (File.directory?(uri) || File.exists?(uri))   
      raise FileNotFoundError, "Directory given (#{uri}) could not be accessed."
    end
    
    include_images = true unless args[:image] == false     
    include_music = true unless args[:music] == false     
    files = []
    if args[:mode] == :single
      files = Dir.glob("#{uri}/*")
    else
      files = Dir.glob("#{uri}/**/*")    
    end
    
    #add all files found to @source_list, if they are music files
    files.each do |f|
      if (Music.is_music?(f) && include_music) || (Image.is_image?(f) && include_images)
        @source_list << f
      end
    end

    return @source_list

  rescue FileNotFoundError => e
    puts e.message
    puts e.backtrace.inspect
    return false
  end

  #alternative run mode. Add multiple "root" directories to scan at once
  def addRoot(dir_uri)
      unless !dir_uri.nil? && dir_uri.is_a?(String) && File.directory?(dir_uri)   
        raise FileNotFoundError, "Directory given (#{dir_uri}) could not be accessed."
      end
      @root_nodes << dir_uri
  rescue FileNotFoundError => e
    puts e.message
    puts e.backtrace.inspect
    return false
  end

  #<<(): synonym for addRoot(). Also a deformed emoticon.
#  def << (dir_uri) addRoot(dir_uri)  end

  #
  #multiscan(): scans multiple directories added to @root_nodes using the addRoot() method.
  #
  #==Inputs
  #===Required
  #none  
  #
  #===Optional
  #(1) Arguments Hash:
  #*:mode => (:single, :multiple) 
  #*:music => (true, false) -- if true, music files will be included in the scan. Set to false to exclude music files. Defaults to true
  #*:image => (true, false) -- if true, image files will be included in the scan. Set to false to exclude image files. Defaults to true
  #
  #==Outputs
  #Array of strings, where each string is a file URI for a music or image file.
  #
  def multiscan(args = {})
    @root_nodes.each do |uri|
      open(uri, args)
    end
    return @source_list
  end
  
end


