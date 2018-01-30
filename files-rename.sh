#!/bin/bash
#
# files-rename.sh
# Nick Howlett 
#
# Description: Renames multiple files all at once. Refer to user guide for more information.
#
# Usage: Refer to user guide for more information.

# get text to prepend from user then format text.
read -p 'Select the text to prepend to each file: ' text
textModified=${text//[ ]/_}

# get renaming system from user.
read -p 'Select N or T as renaming system to append to each file: ' systemRaw

# TODO: get confirmation of system choice from user.

# if user-provided system value doesn't match accepted value then notify user to start again. 
system=$(echo "$systemRaw" | tr '[:lower:]' '[:upper:]') # https://stackoverflow.com/questions/11392189/
if [ $system != 'N' ] && [ $system != 'T' ]; then
  echo "Invalid renaming system choice. Please run script again."
  exit 1
fi

# when using system N get a valid start number (otherwise keep asking until valid).
if [ $system = 'N' ]; then
  declare -i startNumber
  read -p 'Select a starting number: ' startNumber
  while [ $startNumber -le 0 ]; do
    read -p 'Invalid starting number. Select a starting number: ' startNumber
  done
fi

# backup current directory's files, excluding this script, if they don't already exist.
dir=${PWD##*/}
dirBackup="${dir}_backup"
# get script filename then remove quotation marks from string
thisFileName="$(basename \"$0\")"
thisFileName="${thisFileName%\"}"
thisFileName="${thisFileName#\"}"
if [ ! -d "../$dirBackup" ]; then
  mkdir ../$dirBackup
  cp -r -p ./ ../$dirBackup
  rm -f ../$dirBackup/$thisFileName

  # compute total filesizes of both current and backup directories, while excluding this script, first time script is run.
  firstDone=false
  loop=0
  while [ $loop -le 1 ]; do
    if [ "$firstDone" = true ]; then
      cd ../$dirBackup
      fsTotal=0
    else
      # filesize of this script
      fsTotal=-$(stat -f %z $thisFileName)
    fi
    for i in *.*; do
      fs=$(stat -f %z $i)
      fsTotal=$(($fsTotal + $fs))
    done
    fsTotalArray[$loop]=$fsTotal
    firstDone=true
    loop=$(($loop + 1))
  done
  cd ../$dir

  # fail if filesizes of current and backup directories differ.
  if [ ${fsTotalArray[0]} -ne ${fsTotalArray[1]} ]; then
    echo "Failed."
    exit 1
  fi
fi

# TODO: system N: rename files by prepending with user input & appending number incrementally starting from specified start number.
if [ $system = 'N' ]; then
  a=$startNumber
  for i in *.*; do
    # don't include script file in renaming
    if [ $i = $thisFileName ]; then
      continue
    fi
    num=$(printf "%03d" "$a")
    ext="${i##*.}"
    mv -i -- "$i" "${textModified}_$num.$ext"
    let a=a+1
  done
# system T: rename files by prepending with user input & appending individual file's creation date/time. Note file's last modification date/time is used, which will be the same as its creation date/time if the file hasn't been edited).
elif [ $system = 'T' ]; then
  for f in *.*; do
    # don't include script file in renaming
    if [ $f = $thisFileName ]; then
      continue
    fi
    ext="${f##*.}"
    mv -n "$f" "$(date -r "$f" +"${textModified}_%Y%m%d-%H%M%S").$ext"
  done
fi

# TODO: verify renamed files not corrupted.

# notify user that renaming was successful.
echo "Completed. Please check that renamed files have not been corrupted before deleting backup."