Gem::Specification.new do |s|
	s.name 			= "media-organizer"
	s.version 		= "0.1.1"
	s.email 		= "djeserkare@gmail.com"
	s.date 			= "2015-03-01"
	s.files 		= ["lib/media-organizer.rb","lib/renamer.rb","lib/filescanner.rb","lib/scrapers/image.rb","lib/scrapers/music.rb"]
	s.summary 		= "Organize & rename files in bulk based on file metadata."
	s.description 	= "Provides a set of functions for scanning directory trees and dynamically renaming files using their metadata, according to a customizable taxonomy. For example, use media-organizer to set filenames for a directory of photos to a standard such as: \"<date-taken> - Ski Vacation.jpg\". Currently supports only JPEG and TIFF files, and various music formats."
	s.authors 		= ["Stephen Johnson"]
	s.homepage 		=
		'http://rubygems.org/gems/media-organizer'
	s.license		= "MIT"

	s.add_runtime_dependency 'taglib-ruby'
	s.add_runtime_dependency 'exifr'
end

