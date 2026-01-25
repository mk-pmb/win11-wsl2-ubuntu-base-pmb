
cfg.@example
============

To customize config, you can put files in the `cfg.@.defaults` and
`cfg.@<hostname>` subdirectory of the WUB directory,
where `<hostname>` is the (short) hostname as seen from inside WSL.
Files of the same name will be merged if possible;
otherwise, the hostname-specific file will "win".


