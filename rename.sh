#!/bin/bash

# get input to be prepended to each file from user then format.
read -p 'Enter text to prepend to files: ' text
textModified=${text//[ ]/_}

# get valid numbering system choice from user (otherwise keep asking until valid).
read -p "Select numbering system to append to files. Choose either increment based ('N') or date/time based ('T'): " systemRaw
system=$(echo "$systemRaw" | tr '[:lower:]' '[:upper:]') # https://stackoverflow.com/questions/11392189/
while [ $system != 'N' ] && [ $system != 'T' ]; do
  read -p "Numbering system choice not recognised. Enter either 'N' or 'T' to select a numbering system: " systemRaw
  system=$(echo "$systemRaw" | tr '[:lower:]' '[:upper:]')
done

# if increment based numbering chosen get a valid start number from user (otherwise keep asking until valid).
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
    echo "Renaming of files failed. Sorry."
    exit 1
  fi
fi

# rename files using either increment based numbering or date/time based numbering.
if [ $system = 'N' ]; then
  a=$startNumber
  for i in *.*; do
    if [ $i = $thisFileName ]; then
      continue
    fi
    num=$(printf "%03d" "$a")
    ext="${i##*.}"
    mv -i -- "$i" "${textModified}_$num.$ext"
    let a=a+1
  done
elif [ $system = 'T' ]; then
  for f in *.*; do
    if [ $f = $thisFileName ]; then
      continue
    fi
    ext="${f##*.}"
    mv -n "$f" "$(date -r "$f" +"${textModified}_%Y%m%d-%H%M%S").$ext"
  done
fi

# notify user that renaming was successful.
echo "Renaming of files completed. Please check that files have not been corrupted before deleting backup."