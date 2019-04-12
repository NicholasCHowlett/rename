#!/bin/bash

# get text to prepend to each file from user then format text.
read -p 'Enter text to prepend to files: ' text
textModified=${text//[ ]/_}

# get valid renaming system choice from user (otherwise keep asking until valid).
read -p "Select renumbering system to append to files. Enter either 'N' or 'T': " systemRaw
system=$(echo "$systemRaw" | tr '[:lower:]' '[:upper:]') # https://stackoverflow.com/questions/11392189/
while [ $system != 'N' ] && [ $system != 'T' ]; do
  read -p "Renumbering system choice not recognised. Enter either 'N' or 'T' as renumbering system: " systemRaw
  system=$(echo "$systemRaw" | tr '[:lower:]' '[:upper:]')
done

# when using system N get a valid start number from user (otherwise keep asking until valid).
if [ $system = 'N' ]; then
  declare -i startNumber
  read -p 'Enter a starting number: ' startNumber
  while [ $startNumber -le 0 ]; do
    read -p 'Starting number not recognised. Enter a starting number: ' startNumber
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

# system N: rename files by prepending with user input & appending number incrementally starting from specified start number.
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

# notify user that renaming was successful.
echo "Renaming of files completed. Please check that files have not been corrupted before deleting backup."