# Warning: this is meant to be run manually through an irb command line, not as part of "rake test"
# Requires test data in specified directores. WILL OVERWRITE TEST DATA.
require 'media-organizer'

f = Filescanner.new
r = Renamer.new
r.naming_scheme(['Vacation_', :date_time])

imgarr = f.open('./test/data/Disneyland')
list = r.generate(imgarr)
r.overwrite(list)
