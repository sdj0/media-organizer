Gem::Specification.new do |s|
	s.name 			= "media-renamer"
	s.version 		= "0.0.2"
	s.email 		= "djeserkare@gmail.com"
	s.date 			= "2015-02-09"
	s.files 		= ["lib/renamer.rb","lib/media-renamer.rb","lib/scrapers/image.rb","lib/scrapers/music.rb"]
	s.summary 		= "Rename files in bulk based on file metadata."
	s.description 	= "Provides a set of functions for dynamically renaming files using their metadata, according to a customizable taxonomy. For example, use bulk-renamer to set filenames for a directory of photos to a standard such as: \"<date-taken> - Ski Vacation.jpg\". Currently supports only JPEG and TIFF files. Future releases will include support for music and additional image files."
	s.authors 		= ["Stephen Johnson"]
	s.homepage 		=
		'http://rubygems.org/gems/bulk-renamer'
	s.license		= "MIT"

	s.add_runtime_dependency 'taglib-ruby'
	s.add_runtime_dependency 'exifr'
end

