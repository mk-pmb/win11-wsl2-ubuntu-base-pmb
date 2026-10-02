
Lockfiles
=========

Lockfile directory
------------------

We store the lockfiles in `.@local\var\lock`.

From other projects you might be wondering why we don't hide them in the
`.git` directory: To make it work even in a worktree, where `.git` is a file.



Installer and host loop lockfiles
---------------------------------

These are used to avoid conflicting interactions when WUB is updated:

* `wub-instable.lock`:
  Holding this file claims authority for modifying WUB in ways that could
  make it unstable.
  * The updater holds it in order to ensure it can modify any file.
  * The hostLoop (see below) holds it to ensure nobody modifies WUB
    in unstable ways while the guest session is running.

* `wub-hostloop.lock`:
  Held by the hostLoop (`core/keepWslAlive\hostLoop.cmd`)
  to show that it is (currently, already) running.

* `wub-keepalive.lock`:
  Held by the hostLoop while trying to run a guest session with keep-alive.


