require 'taglib'

class FileNotFoundError < StandardError ; end

module Music

	SUPPORTED_FILETYPES = %w{.mp3 .m4a .mp4 .flac .m4a .ogg .aiff .asf .wav}

	def Music.getMusicData(file)
		attributes = {}
	    TagLib::FileRef.open(file) do |fileref|
	      unless fileref.null?
	        #sign tags to local variables
	        tag = fileref.tag
	        properties = fileref.audio_properties
	        
	        #load tags into attributes attribute
	        attributes[:track_name] = tag.title
	        attributes[:track_number] = tag.track
	        attributes[:track_genre] = tag.genre
	        attributes[:track_release_date] = tag.year
	        attributes[:album_name] = tag.album
	        attributes[:artist_name] = tag.artist
	        attributes[:comment] = tag.comment
	        	        
	        attributes[:track_length] = properties.length
	        attributes[:track_bitrate] = properties.bitrate
	        attributes[:track_channels] = properties.channels
	        attributes[:track_sample_rate] = properties.sample_rate
	        
	      end
	    end
	    return attributes
	end

	def Music.supported_filetypes
		reutrn SUPPORTED_FILETYPES		
	end

	def Music.is_music?(uri)
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

