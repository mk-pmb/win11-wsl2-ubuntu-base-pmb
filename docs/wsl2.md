
Notes on WSL 2
==============


Useful WSL user commands
------------------------

* Managing your Ubuntu instances never requires UAC privileges.
  * ⚠ If a WSL command asks for UAC, you mistyped something, and your command
    would probably modify WSL itself, instead of your distro.

* `wsl --list --verbose` example output:

  ```text
    NAME            STATE           VERSION
  * Ubuntu-24.04    Running         2
    Ubuntu-20.04    Running         2
  ```

  `*` = default distro. "Version" here means the WSL version.

* `wsl --set-default Ubuntu-24.04`
* `wsl --install --distribution Ubuntu-24.04`
* `wsl --unregister Ubuntu-24.04`


Detecting the distro's IP address
---------------------------------

* The special hostname `host.docker.internal` is a Docker Desktop feature.
* A more reliable way is to determine the default gateway.
  * Since we install [net-util-pmb](https://github.com/mk-pmb/net-util-pmb/)
    by default, you can use its `ip-dgw-iface` command.
* To detect the windows host IP from the windows side, you can try
  `type \\wsl.localhost\Ubuntu-24.04\mnt\wsl\resolv.conf`








