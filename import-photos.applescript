-- Create a helper null value
set nullValue to missing value

-- Import selected folder
set importFolderPath to POSIX path of (choose folder with prompt "Select a folder to import into Photos")
importFolder(importFolderPath, nullValue)


#############################################
# Recursively import files into an album
#############################################
on importFolder(macFolderPath, photosAlbumParentFolder)

    -- Get the files and folders in the current folder
    set filesInMacFolder to my getAllFilesInMacFolder(macFolderPath)
    set foldersInMacFolder to my getAllMacFoldersInMacFolder(macFolderPath)

    tell application "Photos"

        -- Create a new album for the current folder
        tell application "System Events"
            set macFolderName to name of folder macFolderPath
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

#############################################
# Get all files in a folder
#############################################
on getAllFilesInMacFolder(macFolderPath)

    -- Create a list to store the file paths
    set fileList to {}

    tell application "System Events"
        set folderContents to every file of folder macFolderPath
        repeat with fileItem in folderContents
            set fileItemPath to POSIX path of fileItem
            set end of fileList to fileItemPath
        end repeat
    end tell

    return fileList
end functionName

#############################################
# Get all subfolders in a folder
#############################################
on getAllMacFoldersInMacFolder(macFolderPath)

    -- Create a list to store the file paths
    set folderList to {}

    tell application "System Events"
        set folderContents to every folder of folder macFolderPath
        repeat with fileItem in folderContents
            set fileItemPath to POSIX path of fileItem
            set end of folderList to fileItemPath
        end repeat
    end tell

    return folderList
end functionName