# media-organizer
Media-Organizer is a Ruby gem for automatically renaming and organizing image/music files using their stored metadata. 
You can create your own naming scheme (like "Ski Vacation - \<Date\> - \<Time\>.jpg"), 
and organize entire directory trees of photos according to that scheme. 
This is useful for applications that need a structured method of storing media, like music players and photo galleries.

Full documentation is available at [Rubygems](http://www.rubydoc.info/gems/media-organizer).

## Usage
### The Basics
The basic usage scenaro for Media Organizer is:
  1: Point to folder(s) with some music or image files
  2: Specify a naming and organizing scheme for those files
  3: Generate the new names for those files
  4: Overwrite files, or create copies, with the new names

Here's what the code looks like for this process:

First, use `MediaOrganizer::Filescanner` to load song/image files from a given directory:

```
f = MediaOrganizer::Filescanner.new()
old_files = f.open('/path/to/directory/tree/with/files')

#add some more files from a different directory, but only get music (default is both)
old_files += f.open('/path/to/other/files', music: true, image: false)
```

Then, create a naming scheme for renaming those files. You can reference any of the files'
metadata as a symbol (:date_time, :artist, :title, etc.).

```
scheme = ['Test-', :date_time]
```

Then use `MediaOrganizer::Renamer` to generate the new names for the files. 
```
r = MediaOrganizer::Renamer.new
r.set_naming_scheme(scheme)
new_files = r.generate(old_files)
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

### Notes on Default Behaviors (READ THIS: it's actually pretty important)
There are a few default behaviors you should know about for special cases. The general
design philosophy for Media Organizer is "don't completely die because of a file error." 

#### Missing, Invalid, and Irrelevant Files
Methods like `Filescanner#open` and `Renamer#overwrite` will ignore files they can't handle. For
example, if the file can't be read/edited, is corrupted, is in an unsupported format or can't
be handlded for any other reason, it will be ignored and the method will continue.

#### Missing Metadata
If metadata is empty for a file but is needed in the new file or directory name, it will be replaced
with "Unknown \<field_name\>". For example, if files are to renamed in the format 
`Band Name - Song Title.mp3` but a file lacks the needed :artist metadata, the resulting 
file will be called "Unknown Artist - Song Title.mp3" Duplicates are avoided by appending a number, such as
`Unknown Artist - Unknown Title (1).mp3`.

#### Image vs. Music Files: 
By default, `Filescanner` will pick up all image and music files. Use the `music: false` and
`image: false` arguments to `Filescanner#open` to control this behavior.

### More Obscure Usage

Media Organizer uses support modules called `Scrapers` which pull metadata from image and music
files. These scrapers have some support methods that you may find useful:

```
#Get a list of metadata fields available for a given file
mp3meta = MediaOrganizer::Music.available_metadata(mp3)

#Overwrite metadata for an music file
MediaOrganizer::Music.write_metadata('/music/mixtape/fire/fat_future_beats.mp3', artist: 'Time Traveler', year: 2025))

```

## Examples

### Sorting Vacation Photos
Digital cameras often assign unwieldy file names to photos. Photos can be sorted by the time they 
were taken, and given customizable context names. Here is an example sorting photos from a few 
different vacations using `MediaOrganizer::Filescanner` and `MediaOrganizer::Renamer`.

```
#Setup filescanner and renamer
filescanner = MediaOrganizer::Filescanner.new()
renamer = MediaOrganizer::Renamer.new()

#Load files to rename, and only get images (ignore music)
files = filescanner.open('./Disneyland', music: false)

#Load some more files from another folder
files << filescanner.open('./Disneyland - Phone Pics')

#Setup renamer and overwrite files
renamer.set_naming_scheme(["Disneyland Vacation - ", :date_time]) 
new_files = renamer.generate(files) 
renamer.overwrite(new_files)

```

This will rename all of the files loaded by filescanner.open in place, accoring to 
the `naming_scheme` configured with `renamer.set_naming_scheme`. For example, 
the file `Disneyland/863.jpg` will now become `Disneyland Vacation - 2009-08-15 12_13_32 -0500.JPG`. Since
files that can't be read or written to will be skipped, it is recommended that the `Hash` returned is validated
after each call.


## Development Status
Media-organizer is currently in early development. Supported file formats are: JPEG, TIFF, MP3, M4A, WAV, OGG, and FLAC.


