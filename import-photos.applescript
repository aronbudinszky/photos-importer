###############################################################################################
# This script imports a folder of photos into Photos, creating albums and folders as needed
#
# It will create a new album for each folder it finds, importing all photos in it into the
#   album. If there are subfolders, it will create a folder in Photos and repeat the process.
#
# Written by: Aron Budinszky <aron@budinszky.me>
###############################################################################################

-- Import selected folder
set selectedFolder to POSIX path of (choose folder with prompt "Select a folder to import into Photos")
importFolder(selectedFolder, missing value)

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
    set newPhotosFolder to missing value

    -- Get the name of the current mac folder
    tell application "System Events"
        set macFolderName to name of folder macFolder
    end tell

    tell application "Photos"
        -- If there are subfolders, create a Photos subfolder and add a new album to that
        if foldersInMacFolder is not {} then
            set newPhotosFolder to my createPhotosFolder(macFolderName, photosAlbumParentFolder)
        end if
    end tell

    -- Recursively import all subfolders
    -- (in reverse, because the last one imported will be at the top of the album list)
    repeat with i from (count of foldersInMacFolder) to 1 by -1
        set macFolderItem to item i of foldersInMacFolder
        importFolder(macFolderItem, newPhotosFolder)
    end repeat

    tell application "Photos"
        -- Decide what will be the parent folder
        if newPhotosFolder is missing value then
            set parentFolder to photosAlbumParentFolder
        else
            set parentFolder to newPhotosFolder
        end if

        -- Create album and import all photos
        -- (doing this last so it is at the top of the album list)
        if filesInMacFolder is not {} then
            set newPhotosAlbum to my createPhotosAlbum(macFolderName, parentFolder)
            import filesInMacFolder into newPhotosAlbum
        end if
    end tell
end importFolder

###############################################################################################
# Create a Photos folder
#
# @param folderName The desired name of the folder
# @param photosAlbumParentFolder The parent photo album folder; null if top level
# @returns The new Photos folder
###############################################################################################
on createPhotosFolder(folderName, photosAlbumParentFolder)

    tell application "Photos"
        if photosAlbumParentFolder is missing value then
            set newPhotosFolder to make new folder named folderName
        else
            set newPhotosFolder to make new folder named folderName at photosAlbumParentFolder
        end if
    end tell

    return newPhotosFolder
end createPhotosFolder

###############################################################################################
# Create a Photos album
#
# @param albumName The desired name of the album
# @param photosAlbumParentFolder The parent photo album folder; null if top level
# @returns The new Photos album
###############################################################################################
on createPhotosAlbum(albumName, photosAlbumParentFolder)

    tell application "Photos"
        if photosAlbumParentFolder is missing value then
            set newPhotosAlbum to make new album named albumName
        else
            set newPhotosAlbum to make new album named albumName at photosAlbumParentFolder
        end if
    end tell

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

    set sortedFileList to my sortList(fileList)

    return sortedFileList
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

    set sortedFileList to my sortList(folderList)

    return sortedFileList
end functionName

###############################################################################################
# Sort a list of items alphabetically, such as a file list
#
# @param list The list you want to sort
# @returns The sorted list
###############################################################################################
on sortList(theList)
    set theIndexList to {}
    set theSortedList to {}
    repeat (length of theList) times
        set theLowItem to ""
        repeat with a from 1 to (length of theList)
            if a is not in theIndexList then
                set theCurrentItem to item a of theList as text
                if theLowItem is "" then
                    set theLowItem to theCurrentItem
                    set theLowItemIndex to a
                else if theCurrentItem comes before theLowItem then
                    set theLowItem to theCurrentItem
                    set theLowItemIndex to a
                end if
            end if
        end repeat
        set end of theSortedList to theLowItem
        set end of theIndexList to theLowItemIndex
    end repeat
    return theSortedList
end sortList