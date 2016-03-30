#==Image
#
# The Image module has support methods for validating and loading
# image files, providing image metadata in a hash format. Key API
# methods are `age.get_jpeg_data(file)`, `get_tiff_data(file)`, 
# and `image?(uri)`
#

require 'exifr'

module MediaOrganizer
  module Image
    SUPPORTED_FILETYPES = %w(.jpg .tif).freeze

    def self.get_jpeg_data(file)
      if(self.image?(file))
        meta = EXIFR::JPEG.new(file)
        meta.to_hash
      end
    end

    def self.get_tiff_data(file)
      if(self.image?(file))
        meta = EXIFR::TIFF.new(file)
        meta.to_hash
      end
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
    end
  end
end
