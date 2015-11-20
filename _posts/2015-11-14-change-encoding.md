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

PeopleCode file API function (GetFile, ReadLine, WriteLine etc.) can be used to change file encoding.

{% include custom.html %}

hello

##### Pros

* Simple well documented code already used in lot of places.
* Proper return code and exception handling.
* New file permissions automatically taken care in case of Unix or USS.

##### Cons

* PeopleSoft only supports encoding given in the table PSCHARSETS (also provided in global technology PeopleBook.
http://docs.oracle.com/cd/E41633_01/pt853pbh1/eng/pt/tgbl/concept_UnderstandingCharacterSets-0769d6.html). If you need to work on some other encoding then this approch is not valid.

* This approch is not efficient for large files (125M xml file takes indefinite time).

####2. Java File API





####3. Native encoding APIs
