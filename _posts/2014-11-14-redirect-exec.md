---
layout: post
title: Change file encoding in PeopleCode
description: "Change file encoding in PeopleCode"
modified: 2015-11-14
tags: [PeopleCode]
image:
  feature: abstract-3.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

### Ways to convert file encoding in PeopleCode

Ideally when transferring files to USS using ftp in text mode, the ftp utility automatically converts the file encoding from source native encoding (like WINDOWS-1252) to target native encoding (like IBM-1047) however if we are downloading the attachment to USS using PeopleCode attachment function (like getattachment) this conversion dows not happen (because PeopleSoft stores attachment as hex encoded binary data).

Since on USS most of the utilities expects the file to be encoded in native format, it might be reuired to convert a file from source encoding to USS native encoding.

As part of a new development I had the requirement to convert a file from WINDOWS-1252 code page to IBM-1047 code page.

I evaluated following appraoches each having given pros and cons.

####1. PeopleCode file API

PeopleCode file API function (GetFile, ReadLine, WriteLine etc.) can be used to convert file encoding (as the example given in PeopleBooks).


REM this function, FileEncodingConversion() converts character encoding of 
input file to another of output file.
REM an example of how to call the function is at the end of this file.

Local File &InputFile, &OutputFile;
Local string &InputDirFile, &OutputDirFile, &InputFilename, &OutputFilename;
Local string &sDirSep, &LogLine;
Local array of string &FIleEncoding;
Local boolean &ret;

Function FileEncodingConversion(&InputEncoding, &InputDirectoryFile, 
&OutputEncoding, &OutputDirectoryFile) Returns boolean

   &InputFile = GetFile(&InputDirectoryFile, "R", &InputEncoding, 
%FilePath_Absolute);
   &OutputFile = GetFile(&OutputDirectoryFile, "W", &OutputEncoding, 
%FilePath_Absolute);

   If &InputFile.IsOpen And
&OutputFile.IsOpen Then

      While (&InputFile.readline(&LogLine))
&OutputFile.Writeline(&LogLine);
      End-While;

      &InputFile.Close();
      &OutputFile.Close();
      
      Return True;
      
   Else
      If &InputFile = Null Then
         WinMessage("Error: PeopleCode: File Encoding I/O: " | "Failed to 
open: " | &InputFile.Name);
      Else
         If &OutputFile = Null Then
            WinMessage("Error: PeopleCode: File Encoding I/O: " | "Failed
to open:" | &OutputFile.Name);
         End-If;
      End-If;
      Return False;
   End-If;

End-Function;

/*-----------------------------------------------------------------------*/
/*  Function IsUnix                                                      */
/* check if OS = Unix                                                    */
/*-----------------------------------------------------------------------*/
Function IsUnix Returns boolean
   &DummyFile = GetFile("/bin/sh", "E", %FilePath_Absolute);
   If &DummyFile.IsOpen Then;
      &DummyFile.Close();
      Return True;
   Else;
      Return False;
   End-If;
End-Function;

REM test the function above;
&FIleEncoding = CreateArray("UTF8BOM", "UCS2", "SJIS", "GB18030", "UTF8", "a", "u");

REM WinMessage("ret: " | &ret);

If IsUnix() Then
   /* for UNIX */
   &ret = FileEncodingConversion(&FIleEncoding [1], "/home/FS_" | 
&FIleEncoding [1] | ".txt", &FIleEncoding [2], "/home/BEFORE/FS_PCode_" | &FIleEncoding [1] | "_to_" | &FIleEncoding [2] | ".txt");
Else
   /* for WINDWOS */
   &ret = FileEncodingConversion(&FIleEncoding [1], "D:\TMP\FS_" | 
&FIleEncoding [1] | ".TXT", &FIleEncoding [2], "D:\TMP\AFTER\FS_PCode_" | 
&FIleEncoding [1] | "_to_" | &FIleEncoding [2] | ".TXT");
End-If


##### Pros

* Simple well documented code already used in lot of places.
* Proper return code and exception handling.
* New file permissions automatically taken care in case of Unix or USS.

##### Cons

* PeopleSoft only supports encoding given in the table PSCHARSETS (also given in this link
http://docs.oracle.com/cd/E41633_01/pt853pbh1/eng/pt/tgbl/concept_UnderstandingCharacterSets-0769d6.html). If you need to work on some other encoding then this approch is not valid.

* This approch is not efficient for large files (125M xml file takes indefinite time).

####2. Java File API



####3. Native encoding APIs

