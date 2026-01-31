/* Work-around for https://github.com/PowerShell/PowerShell/issues/15061

========================================================================

For powershell_6.2.7-1.ubuntu.18.04_amd64.deb:

When you install that package on Ubuntu focal, you'll have apt complain
about the broken dependencies, but that broken half-installed package
works well enough for me.

gcc -o pwshWorkaroundQuickstart15061.so -fPIC -pedantic -pedantic-errors \
  -Wall -Wconversion -Werror -Wextra -Wfloat-equal -Wformat=2 \
  -Wshadow -Wunused -rdynamic -ldl -shared pwshWorkaroundQuickstart15061.c -g

LD_PRELOAD="./pwshWorkaroundQuickstart15061.so" pwsh -Command Get-PSProvider

========================================================================

For powershell-lts_7.4.13-1.deb_amd64.deb:

:TODO: Investigate required intercepts.

$ readelf -s /usr/bin/pwsh | grep -iPe 'stat|open'
    18: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND fopen64@GLIBC_2.2.5 (2)
    67: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND open64@GLIBC_2.2.5 (10)
    69: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __fxstat64@GLIBC_2.2.5 (2)
    74: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND dlopen@GLIBC_2.2.5 (11)
   103: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND opendir@GLIBC_2.2.5 (2)
   107: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __fxstatat64@GLIBC_2.4 (7)

*/

#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/statfs.h>
#include <unistd.h>

// strace sees openat, but readlef says pwsh doesn't use that, just open.
typedef int (*open_func_t)(const char *, int, ...);
int open(const char *pathname, int flags, ...) {
  static open_func_t impl = NULL;
  if (!impl) { impl = (open_func_t)(intptr_t)dlsym(RTLD_NEXT, "open"); }
  if (strcmp(pathname, "/proc/mounts") == 0) {
    return impl("/dev/null", flags);
  }
  if (strcmp(pathname, "/proc/self/mounts") == 0) {
    return impl("/dev/null", flags);
  }
  if (strcmp(pathname, "/proc/self/mountinfo") == 0) {
    return impl("/dev/null", flags);
  }
  /* With this, it seems pwsh won't query the mountpoints anymore, but
    it still scans lots of unexpected files (SSH keys, docker images,
    mounted network shares, …) => :TODO: Try to sabotage the espionage. */
  return impl(pathname, flags);
}

// Nonetheless, it seems we can at least speed up the network drive scanning:
int statfs(
  const char *path __attribute__((unused)),
  struct statfs *buf __attribute__((unused))
) {
  errno = EIO;
  return -1;
}
