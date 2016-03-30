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

##Development Status
Media-organizer is currently in early development. Supported file formats are: JPEG, TIFF, MP3, M4A, WAV, OGG, and FLAC.

