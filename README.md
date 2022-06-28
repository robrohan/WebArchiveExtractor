# WebArchiveExtractor

Mac OS X utility to un-archive .webarchive files (like when saving from Safari)

This project was forked from [Vitaly Davidenko's repo on sourceforge](https://sourceforge.net/projects/webarchivext/).

## Usage

You can use the utility graphically by launching WebArchiveExtractor.app directly. [See interface here.](https://robrohan.github.io/WebArchiveExtractor/)

You can also run the same executable from from the command line:

```sht
./WebArchiveExtractor.app/Contents/MacOS/WebArchiveExtractor
```
Running with no arguments will just launch the GUI.

> An ancestor of this project supported Automator Actions at one point. This project does not have this functionality. Use the CLI for programmatic access.

**CLI Usage**

---

Extract contents of `website.webarchive` to a directory named `website` relative to CWD:
```sh
WebArchiveExtractor website.webarchive
```
```sh
WebArchiveExtractor -i website.webarchive
```

---

Define explicit output directory:
```sh
WebArchiveExtractor website.webarchive -o out
```

---

## Build
You *should* be able to automatically build and sign a release for local execution by running this command in the root of the project, even if you are not an Apple developer (assuming you've got the Xcode CLI tools):
```sh
xcodebuild -project WebArchiveExtractor.xcodeproj
```
If the command fails, you'll need to open the project in Xcode to investigate.


The resulting `WebArchiveExtractor.app` should be in `build/Release`. To install, you can just drag it to your Applications directory. 

> Keep in mind that the executable is inside the `.app` bundle. To reference the command in your shell, you can do something like either of the following:

Add to PATH:
```sh
# Add this to your shell's rc file:
export PATH="$PATH:/Applications/WebArchiveExtractor.app/Contents/MacOS/"
```
Symlink to a location already in PATH:
```sh
ln -s /Applications/WebArchiveExtractor.app/Contents/MacOS/WebArchiveExtractor ~/.local/bin/WebArchiveExtractor
```
