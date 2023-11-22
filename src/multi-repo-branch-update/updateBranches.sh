#!/bin/bash

# Pull the helpers into this file
source ../helpers/read-file-into-array.sh


#Usage
updateBranches 




# Set the (eeek) Global Variables that will be used by the functions
declare -a IGNORED_DIRECTORIES=("backup")
declare -a DIRS_TO_UPDATE=()


LOG_FILE="" # Will update with directory once running
LOG_FILE_NAME="updateAllProjects.log"
BASE_REPOS_DIR=""

function print {
	echo -e $1

	# Log this to the log file
	echo -e $1 >> $LOG_FILE
}

function shouldIgnore {
				
	for i in "${IGNORED_DIRECTORIES[@]}"  
	do
		#print "\t\tChecking $i"
		if [ "$i" == "$1" ] ;
		then
			#print "Should Ignore!! $1"
			return 0
		fi
	done 

	return 1
}

# Update all the projects in this array
function updateBranches() {
	arr=("$@")
	print "Starting update of all projects"
	starting_dir=$PWD

	failed_repos=()


	for REPO in "${arr[@]}"
	do

		print "\n---------------------------------------"
		print "Updating Project: $REPO"
		print "---------------------------------------"
		cd "$REPO"
		
		current_branch=$(git branch --show-current)
		print "Current Branch: $current_branch"

		print "Attempting to pull latest code"
		git pull  >> $LOG_FILE 2>> $LOG_FILE

		# Verify the git pull was successful
		if [ $? -eq 0 ]; then
   			print "Success!"
		else
   			echo "------> FAILED"
   			failed_repos+=("$REPO")
		fi

		# Reset working directory back
		cd "$starting_dir"

	done


	#Print the failed repo's as a list here

	if [ -n $failed_repos ]; then

		print "\n========================================"
		print "--->          ERRORS DETECTED        <--"
		print "========================================"

		print "The following repo's couldn't be automatically updated:"

		for FAILED_REPO in "${failed_repos[@]}"
		do
			print "\t- $FAILED_REPO"

		done
	else
		print "All Repo's Successfully updated :) "
	fi


	print "\n------------------"
	print "Update Repo's Done"
	print "------------------"
}


# This function populates the global DIRS_TO_UPDATE by scanning the directory
function scanDirectory {


print "Scanning Directory...."

for directory in "$1"/* 
do
	
	if [ -d "$directory" ]; then # It's a directory
	
		# Verify it doesn't match the ignored directories
		DIR_NAME="$(basename $directory)"


		if shouldIgnore "$DIR_NAME"; then
			print "\tIGNORING: $DIR_NAME"
		else
			#print "$DIR_NAME"
			DIRS_TO_UPDATE+=("$DIR_NAME")
		fi


	fi
done


}


function setupLogFile {

	SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

	# Overwrite the previous log file
	LOG_FILE="$SCRIPT_DIR/$LOG_FILE_NAME"

	echo -e "Starting Script\n" > $LOG_FILE

	print "\n-----------------------------"
	print "Log File Created:\n$LOG_FILE"
	print "-----------------------------\n"
}


function setBaseDirectory {

	print "\nReading from Environment Variable 'REPOS_DIR' Directory: $REPOS_DIR"


	# Get Base REPOS_DIR Environment variable and clean carriage returns
	BASE_REPOS_DIR=$(echo $REPOS_DIR | tr -d '\r')
	# Replace ~ if it's there
	BASE_REPOS_DIR="${BASE_REPOS_DIR/#~/$HOME}"


	print "Changing to: \t$BASE_REPOS_DIR"
	cd "$BASE_REPOS_DIR"
	print "Working Dir: \t$PWD \n"
}


########################################################################
#### Storing Calling Directory
########################################################################
CALLING_DIR=`pwd`
pushd $CALLING_DIR > /dev/null
########################################################################

setupLogFile

setBaseDirectory

scanDirectory $BASE_REPOS_DIR

updateBranches "${DIRS_TO_UPDATE[@]}"


print "\n-----------------------------"
print "Log File Created:\n$LOG_FILE"
print "-----------------------------\n"
print "\nDone.\n"



########################################################################
### Returning to Calling Directory
########################################################################
popd > /dev/null
########################################################################



