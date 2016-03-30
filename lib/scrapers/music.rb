#
# music.rb: defines the scraper module Music, which validates and loads
# music files, providing image metadata in a hash format.
#
require 'taglib'

module MediaOrganizer
  module Music
    SUPPORTED_FILETYPES = %w(.mp3 .m4a .mp4 .flac .m4a .ogg .aiff .asf .wav).freeze

    def self.get_music_data(file)
      attributes = {}
      TagLib::FileRef.open(file) do |fileref|
        unless fileref.null?
          # sign tags to local variables
          tag = fileref.tag
          properties = fileref.audio_properties

          # load tags into attributes attribute
          attributes[:title] = tag.title
          attributes[:track] = tag.track
          attributes[:genre] = tag.genre
          attributes[:year] = tag.year
          attributes[:album] = tag.album
          attributes[:artist] = tag.artist
          attributes[:comment] = tag.comment

          attributes[:length] = properties.length
          attributes[:bitrate] = properties.bitrate
          attributes[:channels] = properties.channels
          attributes[:sample_rate] = properties.sample_rate

        end
      end
      attributes
    end

    def self.supported_filetypes
      reutrn SUPPORTED_FILETYPES
    end

    def self.music?(uri)
      unless !uri.nil? && uri.is_a?(String) && File.exist?(uri)
        raise StandardError, "Directory given (#{uri}) could not be accessed."
      end

      if SUPPORTED_FILETYPES.include?(File.extname(uri).downcase)
        return true
      else
        return false
      end

    rescue FileNotFoundError => e
      puts e.message
      puts e.backtrace.inspect
      return false
    end

    #
    # availableMetadata(file, args): returns list of fields available as metadata for the given file.
    #
    #===Inputs
    # 	*(1) filepath: full/absolute URI of the file to be analyzed. Required input.
    # 	*(2) args: optional arguments passed as hash. Set ":include_null" to false to only return populated metadata fields.
    #
    def self.availableMetadata(filepath = '', args = {})
      attrs = get_music_data(filepath)

      unless args[:include_null] == false
        attrs.each do |field, value|
          attrs.delete(field) if value.nil? || value == ''
        end
      end
      attrs
    end

    #
    # writeMetadata(file = "", meta = {}): returns list of fields available as metadata for the given file.
    #
    #===Inputs
    # 	*(1) filepath: full/absolute URI of the file to be analyzed. Required input.
    # 	*(2) meta: metadata to be written, passed as a hash in the format :metadata_field => metadata_value
    #
    #===Outputs
    # Returns true if the file was successfully saved. Note: true status does not necessarily indicate each field was successfully written.
    #
    #===Examples
    # Music.writeMetadata("/absolute/path/to/file.mp3", {:artist => "NewArtistName", :year => "2019"})
    #
    def self.writeMetadata(filepath, meta = {})
      attributes = {}
      successflag = false
      TagLib::FileRef.open(filepath) do |fileref|
        unless fileref.null?
          # sign tags to local variables
          tag = fileref.tag
          properties = fileref.audio_properties

          meta.each do |field, value|
            if tag.respond_to?(field)
              tag.send("#{field}=", value)
            elsif properties.respond_to?(field)
              properties.send("#{field}=", value)
            end
          end
          successflag = fileref.save
        end
      end
      successflag
    end
  end
end
