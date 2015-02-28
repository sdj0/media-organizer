require 'exifr'

class FileNotFoundError < StandardError ; end

module Image
	SUPPORTED_FILETYPES = %w{.jpg .tif}

	def Image.getJpegData(file)
		meta = EXIFR::JPEG.new(file)
		return meta.to_hash
		#!!! Rescue from common file-related and exifr-related errors here
	end

	def Image.getTiffData(file)
		meta = EXIFR::TIFF.new(file)	
		return meta.to_hash
		#!!! Rescue from common file-related and exifr-related errors here
	end

	def Image.supported_filetypes
		return SUPPORTED_FILETYPES		
	end

	def Image.is_image?(uri)
		unless !uri.nil? && uri.is_a?(String) && File.exists?(uri)
			raise FileNotFoundError, "Directory given (#{uri}) could not be accessed."
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
