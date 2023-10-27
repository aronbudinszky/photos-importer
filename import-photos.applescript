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
set importFolder to POSIX path of (choose folder with prompt "Select a folder to import into Photos")
importFolder(importFolder, nullValue)

###############################################################################################
# Recursively import files into an album
#
# @param macFolder The folder you want to import
# @param photosAlbumParentFolder The parent photo album folder; null if top level
###############################################################################################
on importFolder(macFolder, photosAlbumParentFolder)

    -- Get the files and folders in the current folder
    set filesInMacFolder to my getAllFilesInMacFolder(macFolder)
    set foldersInMacFolder to my getAllMacFoldersInMacFolder(macFolder)

    tell application "Photos"

        -- Create a new album for the current folder
        tell application "System Events"
            set macFolderName to name of folder macFolder
        end tell

        -- Create the album for the current Mac folder
        if photosAlbumParentFolder is missing value then
            set newPhotoAlbum to make new album named macFolderName
        else
            set newPhotoAlbum to make new album named macFolderName at photosAlbumParentFolder
        end if

        -- If there are subfolders, create a folder too
        if foldersInMacFolder is not {} then
            if photosAlbumParentFolder is missing value then
                set newPhotosFolder to make new folder named macFolderName
            else
                set newPhotosFolder to make new folder named macFolderName at photosAlbumParentFolder
            end if
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
# Get all files in a folder
#
# @param macFolder The folder you want to scan
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