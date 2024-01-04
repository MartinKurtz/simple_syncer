#!/bin/bash

# Define the root path where folders with repositories are located
ROOT_PATH="/path/to/repositories"

# Define default FTP user and password
DEFAULT_FTP_USER="anonymous"
DEFAULT_FTP_PASSWORD="password"

# Set download limits for FTP and website mirroring
FILES_PER_SECOND_LIMIT=0.1
FTP_DOWNLOAD_LIMIT_KBPS=100  # Set your desired FTP download limit in kilobytes per second
WEBSITE_DOWNLOAD_LIMIT_KBPS=100  # Set your desired website download limit in kilobytes per second

# Set the maximum number of download tries
MAX_TRIES=3

# Iterate through each folder in the root path
find "$ROOT_PATH" -maxdepth 1 -type d | while read -r folder; do
    # Check if it's a directory
    if [ -d "$folder" ]; then
        # Define the path for the source text file within each folder
        source_text_file="$folder/source.txt"

        # Check if the source text file exists
        if [ -f "$source_text_file" ]; then
            echo "Processing folder: $folder"
            echo "  - Reading source text file: $source_text_file"

            # Create a mirror folder inside the repository folder
            mirror_folder="$folder/_mirror"
            mkdir -p "$mirror_folder"

            # Extract repository type and internet address from the text file
            repository_type=$(grep -i "repository_type" "$source_text_file" | cut -d'=' -f2 | tr -d '[:space:]')
            internet_address=$(grep -i "internet_address" "$source_text_file" | cut -d'=' -f2 | tr -d '[:space:]')

            # Check if the mirror folder already exists
            if [ -d "$mirror_folder" ]; then
                echo "  - Mirror folder exists. Updating..."

                # Use the appropriate tool for updating the mirror folder based on the repository type
                case "$repository_type" in
                    "git")
                        # Check if it's a Git repository before attempting to update
                        if [ -d "$mirror_folder/.git" ]; then
                            branch=$(grep -i "branch" "$source_text_file" | cut -d'=' -f2 | tr -d '[:space:]' || echo "main")
                            echo "  - Updating Git repository ($branch branch): $internet_address"
                            cd "$mirror_folder"
                            git pull origin "$branch"
                        else
                            echo "  - Cloning Git repository: $internet_address"
                            branch=$(grep -i "branch" "$source_text_file" | cut -d'=' -f2 | tr -d '[:space:]' || echo "main")
                            git clone -b "$branch" "$internet_address" "$mirror_folder"
                        fi
                        ;;
                    "svn"|"subversion")
                        echo "  - Updating Subversion repository: $internet_address"
                        # Check if the mirror folder is already a Subversion working copy
                        if [ -d "$mirror_folder/.svn" ]; then
                            cd "$mirror_folder"
                            svn update
                        else
                            echo "  - Checking out Subversion repository: $internet_address"
                            svn checkout "$internet_address" "$mirror_folder"
                        fi
                        ;;
                    "ftp")
                        echo "  - Mirroring FTP server: $internet_address with download limit $FTP_DOWNLOAD_LIMIT_KBPS KB/s"
                        # Modify this command based on the specific requirements for mirroring FTP
                        trickle -s -d "$FTP_DOWNLOAD_LIMIT_KBPS"  wget --wait "$FILES_PER_SECOND_LIMIT" --recursive --tries="$MAX_TRIES" --no-clobber --no-parent --ftp-user="${DEFAULT_FTP_USER}" --ftp-password="${DEFAULT_FTP_PASSWORD}" -P "$mirror_folder" "$internet_address"
                        ;;
                    "website")
                        echo "  - Scraping website: $internet_address with download limit $WEBSITE_DOWNLOAD_LIMIT_KBPS KB/s"
                        # Modify this command based on the specific requirements for scraping websites
                        trickle -s -d "$WEBSITE_DOWNLOAD_LIMIT_KBPS" wget --wait "$FILES_PER_SECOND_LIMIT" --recursive --tries="$MAX_TRIES" --no-clobber --page-requisites --html-extension --convert-links --domains "$internet_address" --no-parent -P "$mirror_folder" "$internet_address"
                        ;;
                    *)
                        echo "  - Unknown repository type: $repository_type"
                        ;;
                esac
            else
                echo "  - Mirror folder does not exist. Creating..."

                # Use the appropriate tool for cloning the repository
                case "$repository_type" in
                    "git")
                        branch=$(grep -i "branch" "$source_text_file" | cut -d'=' -f2 | tr -d '[:space:]' || echo "main")
                        echo "  - Cloning Git repository ($branch branch): $internet_address"
                        git clone -b "$branch" "$internet_address" "$mirror_folder"
                        ;;
                    "svn"|"subversion")
                        echo "  - Checking out Subversion repository: $internet_address"
                        svn checkout "$internet_address" "$mirror_folder"
                        ;;
                    "ftp")
                        echo "  - Mirroring FTP server: $internet_address with download limit $FTP_DOWNLOAD_LIMIT_KBPS KB/s"
                        # Modify this command based on the specific requirements for mirroring FTP
                        trickle -s -d "$FTP_DOWNLOAD_LIMIT_KBPS" wget --wait "$FILES_PER_SECOND_LIMIT" --recursive --tries="$MAX_TRIES" --no-clobber --no-parent --ftp-user="${DEFAULT_FTP_USER}" --ftp-password="${DEFAULT_FTP_PASSWORD}" -P "$mirror_folder" "$internet_address"
                        ;;
                    "website")
                        echo "  - Scraping website: $internet_address with download limit $WEBSITE_DOWNLOAD_LIMIT_KBPS KB/s"
                        # Modify this command based on the specific requirements for scraping websites
                        trickle -s -d "$WEBSITE_DOWNLOAD_LIMIT_KBPS" wget --wait "$FILES_PER_SECOND_LIMIT" --recursive --tries="$MAX_TRIES" --no-clobber --page-requisites --html-extension --convert-links --domains "$internet_address" --no-parent -P "$mirror_folder" "$internet_address"
                        ;;
                    *)
                        echo "  - Unknown repository type: $repository_type"
                        ;;
                esac
            fi
        else
            echo "No source text file found in folder: $folder"
        fi
    fi
done

echo "Script execution completed."
