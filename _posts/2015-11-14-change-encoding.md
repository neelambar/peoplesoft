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

{% include 1-2015-11-14-change-encoding.html %}
 

##### Pros

* Simple well documented code already used in lot of places.
* Proper return code and exception handling.
* New file permissions automatically taken care in case of Unix or USS.

##### Cons

* PeopleSoft only supports encoding given in the table PSCHARSETS (also provided in global technology PeopleBook.
http://docs.oracle.com/cd/E41633_01/pt853pbh1/eng/pt/tgbl/concept_UnderstandingCharacterSets-0769d6.html). If you need to work on some other encoding then this approch is not valid.

* This approch is not efficient for large files (125M xml file takes indefinite time).

####2. Java File API

You can also access java file API from PeopleCode to read and write file using java supported encodings.

{% include 2-2015-11-14-change-encoding.html %}

If java 7 or above is available then you can read whole file like

{% highlight java %}
String contents = new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
// or equivalently:
StandardCharsets.UTF_8.decode(ByteBuffer.wrap(Files.readAllBytes(path)));
{% endhighlight %}
 
##### Pros

* Can use all the encodings which java suppors (This is the list https://docs.oracle.com/javase/8/docs/technotes/guides/intl/encoding.doc.html).
* Can get rid of line by line reading if java 7 (or higher) or some utility (like Apatche Commons) is available.

##### Cons

* Sometimes consumes exccessive memory (specially on USS).
* Not recommended for large files.

####3. Native encoding APIs

I think these are the best approaches from robustness as well as performance point of view.

On WIndows servers, powershell can be used like below.

{% include 3-2015-11-14-change-encoding.html %}

With this appraoch I managed to change file enconding  + lot of regex find replace on a 500mb file in 7 seconds (on a decent window server).

On Unix if "iconv" utility is available then it can be used like below.

{% include 4-2015-11-14-change-encoding.html %}

Remeber to include shell ("sh -c") when using re-direction or pipe. Following command will work on a console but when executed from PeopleSoft it will not generate a file and output will be re-directed to PeopleSoft stdout and stderror.

&ExitCode = Exec(""iconv -f 1252 -t IBM-1047 \apps\user\temp\in.txt > \apps\user\temp\out.txt", %Exec_Synchronous + %FilePath_Absolute);

In-stead of using Exec function you can use Java "Runtime" exec method also as shown in this blog (http://jjmpsj.blogspot.pt/2010/02/exec-processes-while-controlling-stdin.html)

