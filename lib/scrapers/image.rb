#
# image.rb: defines the class Image, which validates and loads
# image files, providing image metadata in a hash format.
#

require 'exifr'

module MediaOrganizer
  module Image
    SUPPORTED_FILETYPES = %w(.jpg .tif).freeze

    def self.get_jpeg_data(file)
      meta = EXIFR::JPEG.new(file)
      meta.to_hash
      # !!! Rescue from common file-related and exifr-related errors here
    end

    def self.get_tiff_data(file)
      meta = EXIFR::TIFF.new(file)
      meta.to_hash
      # !!! Rescue from common file-related and exifr-related errors here
    end

    def self.supported_filetypes
      SUPPORTED_FILETYPES
    end

    def self.image?(uri)
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
  end
end
