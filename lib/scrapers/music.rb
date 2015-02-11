require 'taglib'

module Music
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

end

