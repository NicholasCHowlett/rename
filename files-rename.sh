#!/bin/bash
#
# files-rename.sh
# Nick Howlett 
#
# Description: Renames multiple files all at once. Refer to user guide for more information.
#
# Usage: Refer user guide for more information.

# get text to prepend from user then format text.
read -p 'Select the text to prepend to each file: ' text
textModified=${text//[ -]/_}

# get renaming system from user.
read -p 'Select N or T as renaming system to append to each file: ' systemRaw

# TODO: get confirmation of system choice from user.

# if user-provided system value doesn't match accepted value then notify user to start again.
system=$(echo "$systemRaw" | tr '[:lower:]' '[:upper:]')
if [ $system != 'N' ] && [ $system != 'T' ]; then
  echo "Invalid renaming system choice. Please run script again."
  exit 1
fi

# backup current directory's files.
dir=${PWD##*/}
dirBackup="${dir}_backup"
mkdir ../$dirBackup
cp -r -p ./ ../$dirBackup

# compute total filesizes of both current and backup directories.
firstDone=false
loop=0
while [ $loop -le 1 ]; do
  if [ "$firstDone" = true ]; then
    cd ../$dirBackup
  fi
  fsTotal=0
  for i in *.*; do
    fs=$(stat -f %z $i)
    fsTotal=$(($fsTotal + $fs))
  done
  fsTotalArray[$loop]=$fsTotal
  firstDone=true
  loop=$(($loop + 1))
done

# abort if filesizes of current and backup directories differ.
if [ ${fsTotalArray[0]} -ne ${fsTotalArray[1]} ]; then
  echo Failed.
  exit 1
fi

# system N: rename files by prepending with user input & appending number incrementally starting from the number 001.
cd ../$dir
if [ $system = 'N' ]; then
  a=1
  for i in *.*; do
    num=$(printf "%03d" "$a")
    ext="${i##*.}"
    mv -i -- "$i" "${textModified}_$num.$ext"
    let a=a+1
  done
# system T: rename files by prepending with user input & appending individual file's creation date/time. Note file's last modification date/time is used, which will be the same as its creation date/time if the file hasn't been edited).
elif [ $system = 'T' ]; then
  for f in *.*; do
    ext="${f##*.}"
    mv -n "$f" "$(date -r "$f" +"${textModified}_%Y%m%d-%H%M%S").$ext"
  done
fi

# TODO: verify renamed files not corrupted.

# notify user that renaming was successful.
echo Completed. Please check that renamed files have not been corrupted before deleting backup.