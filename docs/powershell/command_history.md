
Command History
===============


Clearing the history
--------------------

* [MS Learn: Clear-History doesn't clear the history](https://web.archive.org/web/2025/https://learn.microsoft.com/en-us/archive/blogs/stevelasker/clear-history-powershell-doesnt-clear-the-history-3)

Well, actually, `Clear-History` *does* indeed clear PowerShell's command
history for the current session, as can be verified using `Get-History`.
However, what you use when you type the up/down arrow keys,
that is handled by a separate feature: The PowerShell Readline History,
which additionally stores and loads a persistent history file.

You can disable it for the current shell session with this command:

```pwsh
Set-PSReadLineOption -HistorySaveStyle SaveNothing
```


Configuring local PowerShell sessions
-------------------------------------

To make it the default for future powershell sessions, you can create a
profile file (ideally as UTF-8-BOM text) at path `$PROFILE.CurrentUserAllHosts`
and add the command there.


### Enabling profile file execution

However, when you first create that profile file on a fresh install,
you'll find that PowerShell instead greets you with a warning that your profile
wasn't loaded because system config forbids executuing the file.
In this case, you can override the system config using command line switches
when invoking PowerShell, e.g. `-ExecutionPolicy RemoteSigned -NoLogo -NoExit`.

To change the default options for the "Terminal" entries in the Quick Link Menu
(aka PowerUser Menu, opens with logo key + X), you need to configure the
Windows Terminal options, because those menu items just launch WT. To do so,
start the terminal as usual, then at the end of the shell tabs bar
there should be a "+" symbol and an downwards arrow symbol. The latter opens
a menu where near the bottom you should find the "Settings" entry,
usually also available with Ctrl + comma.
In the lefthand navigation list, locate the "Profile" section, and in it, the
"Windows PowerShell" entry. When you click it, the options open to the right.
Near the top you can find the command line to invoke, where you can add
your options. Near the top you may also set the default working directory.
In the bottom left, there is a button to open your current terminal config
JSON file. When you hover it, it shows instructions for how to open the
default config JSON file.


### Startup script for incoming SSH sessions

When you log into PowerShell via SSH, you'll encounter the execution policy
problem again.
There is also a `Subsystem powershell` line in
`$env:ProgramData\ssh\sshd_config`, which usually has `-sshs -NoLogo` already.
For me, that entry had no effect at all: Most obviously, my SSH sessions
do start with the PowerShell Logo, despite `-NoLogo`.
Also the `-sshs` option is rumored to disable any profile loading,
in which case execution policy should have been irrelevant.
(Documentation on `-sshs` is very sparse, and it doesn't show up in
`powershell.exe -help | grep -i ssh`.
When I manually run `powershell.exe -sshs`, it complains about `-sshs` not
being a proper cmdlet.)
Even when I replaced the command with a bogus one and restarted the OpenSSH
service, nothing changed. Even commenting out the subsystem line had no effect.

Subsystems not being concerned was expected though, since my SSH client
(openssh on Ubuntu) didn't request any. Instead, the default shell setting
should have applied, registry string `HKLM\SOFTWARE\OpenSSH\DefaultShell`.
It defaults to the full path of `powershell.exe` with no CLI arguments.
That is in accordance with the official documentation
[in the PowerShell wiki][sshd-dfsh-pswiki] and [on MS Learn][sshd-dfsh-mslearn].
Both do not mention OpenSSH versions, so in theory it should work on all
Windows OpenSSH versions.

  [sshd-dfsh-pswiki]: https://github.com/PowerShell/Win32-OpenSSH/wiki/DefaultShell
  [sshd-dfsh-mslearn]: https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh-server-configuration

The official docs also explain that you can use a companion registry string
`DefaultShellCommandOption` to set command line options.
You shouldn't use `-NoExit` here, so you only set
`-NoLogo -ExecutionPolicy RemoteSigned`.
It may be overwritten by the HKCU version of the string,
which by default should not exist.
Again, remember to restart the OpenSSH service.
However, that had no effect for me.
So I tried setting `DefaultShell` to the full path of `netsh.exe`,
and discovered that it actually applies when I restart the entire computer,
not just the OpenSSH service. SSH login now gave me a netsh prompt,
with no complaints about invalid arguments, so it seems that
`DefaultShellCommandOption` was ignored entirely.
Giving command options in `DefaultShell` made my SSH login fail.

To summarize:
* We can select a default shell by giving a full path (just the plain path,
  no quotes, no arguments) in `DefaultShell`.
* `DefaultShellCommandOption` is ignored.
* Changes apply only when you restart the entire computer.
* Side note: Changes to `sshd_config` seem to also only apply when I restart
  the computer.

Which gave me an idea for a work-around:
Set `DefaultShell` to `%ProgramData%\ssh\login.cmd`.
Create a batch script at that location with:

```batch
@echo off
c:
cd \
if "%~1" == "-c" goto cmd
powershell.exe -NoLogo -ExecutionPolicy RemoteSigned
goto end
:cmd
%~2
:end
```

* Restart the computer.
* Success! Standard SSH login (without a remote command) now yieds a
  powershell with no history saving, while at least simple remote commands
  (where quoting doesn't interfere) are still supported.












