require 'exifr'

module Image
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
end
