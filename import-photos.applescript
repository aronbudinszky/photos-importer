###############################################################################################
# This script imports a folder of photos into Photos, creating albums and folders as needed
#
# It will create a new album for each folder it finds, importing all photos in it into the
#   album. If there are subfolders, it will create a folder in Photos and repeat the process.
#
# Written by: Aron Budinszky <aron@budinszky.me>
###############################################################################################

-- Create a helper null value
set nullValue to missing value

-- Import selected folder
set selectedFolder to POSIX path of (choose folder with prompt "Select a folder to import into Photos")
importFolder(selectedFolder, nullValue)

###############################################################################################
# Recursively import files into Photos albums and folders
#
# @param macFolder The folder you want to import
# @param photosAlbumParentFolder The parent photo album folder; null if top level
###############################################################################################
on importFolder(macFolder, photosAlbumParentFolder)

    -- Get the files and folders in the current folder
    set filesInMacFolder to my getAllFilesInMacFolder(macFolder)
    set foldersInMacFolder to my getAllMacFoldersInMacFolder(macFolder)

    tell application "Photos"

        -- Create a new Photos folder for the current Mac folder
        tell application "System Events"
            set macFolderName to name of folder macFolder
        end tell

        -- If there are subfolders, create a Photos subfolder and add a new album to that
        if foldersInMacFolder is not {} then
            set newPhotosFolder to my createPhotosFolder(macFolderName, photosAlbumParentFolder)
            set newPhotosAlbum to my createPhotosAlbum(macFolderName, newPhotosFolder)
        else
            -- ...otherwise create an album directly in the parent folder
            set newPhotosAlbum to my createPhotosAlbum(macFolderName, photosAlbumParentFolder)
        end if

        -- Import all files in the current album
        import filesInMacFolder into newPhotoAlbum        
    end tell

    # Recursively import all subfolders
    repeat with macFolderItem in foldersInMacFolder
        importFolder(macFolderItem, newPhotosFolder)
    end repeat

end importFolder

###############################################################################################
# Create a Photos folder
#
# @param name The desired name of the folder
# @param photosAlbumParentFolder The parent photo album folder; null if top level
# @returns The new Photos folder
on createPhotosFolder(name, photosAlbumParentFolder)

    if photosAlbumParentFolder is missing value then
        set newPhotosFolder to make new folder named name
    else
        set newPhotosFolder to make new folder named name at photosAlbumParentFolder
    end if

    return newPhotosFolder
end createPhotosFolder

###############################################################################################
# Create a Photos album
#
# @param name The desired name of the album
# @param photosAlbumParentFolder The parent photo album folder; null if top level
# @returns The new Photos album
on createPhotosAlbum(name, photosAlbumParentFolder)

    if photosAlbumParentFolder is missing value then
        set newPhotosAlbum to make new album named name
    else
        set newPhotosAlbum to make new album named name at photosAlbumParentFolder
    end if

    return newPhotosAlbum
end createPhotosAlbum

###############################################################################################
# Get all files in a folder
#
# @param macFolder The folder you want to scan
# @returns A list of files in the folder
###############################################################################################
on getAllFilesInMacFolder(macFolder)

    set fileList to {}

    tell application "System Events"
        set folderContents to every file of folder macFolder
        repeat with fileItem in folderContents
            set fileItemPath to POSIX path of fileItem
            set end of fileList to fileItemPath
        end repeat
    end tell

    return fileList
end functionName

###############################################################################################
# Get all subfolders in a folder
#
# @param macFolder The folder you want to scan
# @returns A list of folders in the folder
###############################################################################################
on getAllMacFoldersInMacFolder(macFolder)

    set folderList to {}

    tell application "System Events"
        set folderContents to every folder of folder macFolder
        repeat with fileItem in folderContents
            set fileItemPath to POSIX path of fileItem
            set end of folderList to fileItemPath
        end repeat
    end tell

    return folderList
end functionName