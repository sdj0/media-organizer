# media-organizer
Media-Organizer is a Ruby gem for automatically renaming and organizing image/music files using their stored metadata. 
You can create your own naming scheme (like "Ski Vacation - \<Date\> - \<Time\>.jpg"), 
and organize entire directory trees of photos according to that scheme. 
This is useful for applications that need a structured method of storing media, like music players and photo galleries.

Full documentation is available at [Rubygems](http://www.rubydoc.info/gems/media-organizer).

##Usage
First, use Filescanner to load song/image files from a given directory:

Then, create a naming scheme for renaming those files. You can reference any of the files'
metadata as a symbol (:date_time, :artist, :title, etc.).

```
scheme = ['Test-', :date_time]
```

Then use `MediaOrganizer::Renamer` to generate the new names for the files. 
```
r = MediaOrganizer::Renamer.new
r.set_naming_scheme(scheme)
new_uris = r.generate(old_uris)
```
Note that this only creates a mapping between old file names and new file names; it won't
overwrite the old files yet. It is recommended that the new 
filenames be validated for completeness, since some file metadata may be missing or corrupted.

Finally, call `#overwrite` to change the filenames in-place.

```
r.overwrite(new_uris)
```

If for some reason any of the files can't be overwritten, such as lack of write access or 
the file is locked by another process, those files will be skipped. An error is printed for
each file skipped in this manner. 

##Examples

###Sorting Vacation Photos
Digital cameras often assign unwieldy file names to photos. Photos can be sorted by the time they 
were taken, and given customizable context names. Here is an example sorting photos from a few 
different vacations using `MediaOrganizer::Filescanner` and `MediaOrganizer::Renamer`.

```
#Setup filescanner and renamer
filescanner = MediaOrganizer::Filescanner.new()
renamer = MediaOrganizer::Renamer.new()

#Load files to rename
files = filescanner.open './Disneyland'

#Load some more files from another folder
files << filescanner.open './Disneyland - Phone Pics'

#Setup renamer and overwrite files
renamer.set_naming_scheme(["Disneyland Vacation - ", :date_time]) # => ["Disneyland Vacation - ", :date_time] 
new_files = renamer.generate(files) # => {"./Disneyland/863.JPG"=>"Disneyland Vacation - 2009-08-15 12_13_32 -0500.JPG", [...]
renamer.overwrite(new_files) #=> {"./Disneyland/863.JPG"=>"Disneyland Vacation - 2009-08-15 12_13_32 -0500.JPG", [...]

```

This will rename all of the files loaded by filescanner.open in place, accoring to 
the `naming_scheme` configured with `renamer.set_naming_scheme`. For example, 
the file `Disneyland/863.jpg` will now become `Disneyland Vacation - 2009-08-15 12_13_32 -0500.JPG`. Since
files that can't be read or written to will be skipped, it is recommended that the `Hash` returned is validated
after each call.


##Development Status
Media-organizer is currently in early development. Supported file formats are: JPEG, TIFF, MP3, M4A, WAV, OGG, and FLAC.


