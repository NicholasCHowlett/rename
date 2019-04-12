# rename
Renames all files within a single directory to a combination of user-supplied portion that is prepended and number portion that is appended to each file (e.g. nhowlett_cat_001.JPG). This program was developed to help me organise my digital photographs.

The prepended portion is specified once by you the user (and is the same for all files), while the appended number portion is unique to each file. The numbered portion can either be increment based (e.g. 001.txt, 002.txt, 003.txt, etc) or file creation date/time based (e.g. 20190130-124500.txt, 20190130-125000.txt, 20190130-125500.txt, etc). Please refer to the User guide for more details.

## How to use this program
Please refer to the User guide (rename_user-guide.pdf) for details.

## Licensing
This project is licensed under the terms of the MIT License (LICENSE.txt).

## Changelog
Unreleased: Get confirmation of numbering system choice from user.  
Unreleased: Verify renamed files not corrupted.  

[2019-04-12 14:54] Changed: Updated text displayed to user to match terminology in user guide.  
[2019-04-12 11:57] Changed: Updated text displayed to user.  
[2018-01-30 21:47] Changed: Program keeps asking user for numbering system if user's choice is not valid.  
[2018-01-30 21:36] Changed: Increment based numbering system allows user to specify starting number.  
[2018-01-30 21:28] Fixed: Program doesn't fail when rerun.  
[2018-01-30 21:22] Fixed: Program file excluded from renaming & backing up.  
[2018-01-30 21:18] Fixed: Program can be executed multiple times.  
[2018-01-30 21:14] Added: Renames & backs up all files within a directory.