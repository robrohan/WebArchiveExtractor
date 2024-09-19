# WebArchive Extractor

WebArchive Extractor is a MacOS application to help un-archive `.webarchive`
files (like when saving from Safari).

If you do not want to build the code yourself, you can grab a compiled
[universal binary here](https://therohans.com/webarchiveextractor/).

## Compiling

You should be able to just checkout the code, open in Xcode, and click run.

## Building Help

```
cd WebArchiveExtractorHelp
```

```
hiutil -I corespotlight -Caf WebArchiveExtractorHelp.cshelpindex -vv .
```

```
hiutil -I lsm  -Caf WebArchiveExtractorHelp.helpindex -vv .
```

Verify:

```
hiutil -I corespotlight -Tvf WebArchiveExtractorHelp.cshelpindex
```

```
mv WebArchiveExtractorHelp WebArchiveExtractorHelp.help
```

---

NOTE: this file is from the original sourceforge code. There is no Automator 
code in this forked version

Release notes

Version 0.1 - initial release 
This release contains two independent parts

Part 1. Application 'Web Archive Extractor'

files:
WebArchiveExtractor.zip contains Application

To install 'Web Archive Extractor'
 - unpack WebArchiveExtractor.zip
  - copy WebArchiveExtractor into /Application folder 


Part 2. Automator Action

files:
Automator-WebArchiveExtractorAction.action.zip  contains Automator Plugin
Automator-ExtractWebarchive.zip contains sample workflow

To install Automator Action 
 - unpack zip 
 - copy WebArchiveExtractorAction.action into  /Users/<your username>/Library/Automator folder


Version 0.2
Version 0.2 improves stability and addresses a number of other minor issues.
-crash on releasing of autorelease pool fixed (in NSCoreDragReceiveProc)
-main resource name changed to webarchive-index.html
-bundle identifiers changed

files:
WebArchiveExtractor.0.2.zip  contains Application
Automator-WebArchiveExtractorAction.0.2.action.zip  contains Automator Plugin

.
