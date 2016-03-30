# media-organizer
Media-Organizer is a Ruby gem for renaming and organizing image and music files using their metadata. 
You can create your own naming scheme (like "Ski Vacation - \<Date\> - \<Time\>.jpg"), 
and organize entire directory trees of photos according to that scheme. 
This is useful for applications that need a structure method of storing media files, like music players and photo galleries.

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



