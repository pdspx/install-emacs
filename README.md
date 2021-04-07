# Install Emacs

My really bad, exceptionally rudimentary script that I use to build Emacs from source. It build Emacs with some performance related `CFLAGS` in a "ramdisk" (tmpfs).

## Running

Either `./install-emacs.sh` or `./install-emacs.sh native`. The first option will build the latest version from the `emacs-mirror` repo, the second will do the same but with native compilation enabled.

## Contributions

I'm terrible with shell scripting, so if anyone would like to help beef up the script, feel free to open a pull request or issue.

## License

The Unlicense. See the LICENSE file for more info.
