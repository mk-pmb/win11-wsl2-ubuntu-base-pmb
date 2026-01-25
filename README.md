
<!--#echo json="package.json" key="name" underline="=" -->
win11-wsl2-ubuntu-base-pmb
==========================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Make Ubuntu work for me in Windows 11 WSL2.
<!--/#echo -->



Definitions
-----------

* __WSL__: [Windows Subsystem for Linux][wp-en-wsl]
* __WUB__: Acronym for this project,
  made from the initials of its relevant words: WSL, Ubuntu, Base.



Usage
-----

* `wub.cmd`: Open PowerShell in the WUB directory.
* `wub.cmd .`: Open the WUB directory in Windows Explorer.



Installation
------------

* If you use the OpenSSH Windows service, reconfigure it to use some port
  other than 22 and restart it.
  * Or you can (later) reconfigure the OpenSSHd inside your WSL
    and adjust the port forwarding as needed.
* If you want a specific version of any of these programs,
  install them before WUB, otherwise WUB may try to install them
  at whatever version is easiest to get.
  Detection is done by whether WUB can run the expected `.exe` files.
  * `choco.exe` = Chocolatey
  * `node.exe` = Node.js
  * `perl.exe` = Perl
  * `pythonw3.exe` = Python 3
* Plan ahead for restarting Windows soon, as that will be required later,
  after WUB claims it is successfully installed.
* Ensure your computer name is sane, and entirely lowercase.
  * If Windows won't allow you to change just letter case, you may have to
    (optionally: complain to Microsoft,)
    set a temporary dummy hostname, reboot,
    change it to your original hostname in lowercase, and reboot again.
* Install [ncat](https://nmap.org/ncat/) if you haven't already:
  Make sure you have `ncat.exe` in your [`PATH`][wp-en-path-var].
  The download link for the statically compiled version of `ncat.exe` is
  hidden near the botton: "[…] inside a zip file [here][ncat-zip]."
  * I actually made a downloader in the install script,
    and even managed to trick Windows Defender to leave the ZIP file alone,
    but it would still confiscate the unpacked exe file, so you'll have to
    deal with it manually.
* Check `netsh.exe interface portproxy show all` for any forwardings for which
  you don't have a good reason to keep them. For help on how to delete them:
  `netsh.exe interface portproxy delete` (shows available subcommands)
* Install the latest Ubuntu LTS from the Windows Store.
  * Recommended initial username: `wubu-pmb` (The second "u" is for user.)
  * Recommended initial password (will be disabled later): `wubu`
* Create a directory for this repo somewhere on a windows disk where each
  path component consists of only letters (`A-Z`, `a-z`), digits (`0-9`),
  U+002D hyphen-minus (`-`), U+002E full stop (`.`),
  and/or U+005F low line (`_`).
  * We'll call this your _WUB directory_.
  * Recommended path: `C:\ProgramData\win11-wsl2-ubuntu-base-pmb`
* In your WUB directory, make a directory named `cfg.@.defaults`
  and maybe put some files there:
  * `ssh_authorized_keys.txt`: If you want to login via OpenSSH.
    * A potential UTF-8-BOM (Byte Order Mark) in the first line is acceptable.
    * U+000D carriage return (cr) at the end of lines are acceptable.
* Download [`reinstall_repo.cmd`](reinstall_repo.cmd) into your WUB directory,
  open its file properties, confirm the trust checkbox (web download
  noob protection) in the bottom, click "OK", and run it.
* It should install lots of stuff and then say
  "Post-install configuration completed successfully."
* Type any key (e.g. space bar) to quit.
* Restart Windows.


  [wp-en-path-var]: https://en.wikipedia.org/wiki/PATH_%28variable%29
  [ncat-zip]: https://web.archive.org/web/20251203182724/https://nmap.org/dist/ncat-portable-5.59BETA1.zip



Known issues
------------

* Needs more/better tests and docs.
* `ERR_OUTDATED_WSL_PATH`:
  The installer was able to install missing packages, but it cannot see them
  because the WSL session still uses the old `PATH` environment variable.
  The solution is to retry with a new environment inherited directly from the
  windows task bar: If a shell is still open from which you launched the
  current (failed) attempt, close it. Press Win+R to open the "Run" dialog,
  type `wub` and confirm to open the WUB shell.
  There, run `reinstall_repo.cmd`. If that didn't help, reboot and retry.







<!--#toc stop="scan" -->

&nbsp;


  [wp-en-wsl]: https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux


License
-------
<!--#echo json="package.json" key="license" -->
ISC
<!--/#echo -->
