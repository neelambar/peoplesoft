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

1. PeopleCode file API

2. Java File API

3. Native encoding APIs
