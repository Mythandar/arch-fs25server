# Safe replacement testing on TrueNAS

The existing `arch-fs25server` container and `/mnt/Main/fs25` data are out of
scope for all test commands. The replacement uses a different container name,
ports, and host directories.

## Test paths

Create these empty paths as UID/GID `99:100`:

```bash
mkdir -p /mnt/Main/fs25-test/{config,game,dlc,installer}
mkdir -p /mnt/JailHouse/VirtualMachines/FS25-test
chown -R 99:100 /mnt/Main/fs25-test /mnt/JailHouse/VirtualMachines/FS25-test
```

For a realistic test, use TrueNAS/ZFS snapshots and writable clones of the live
FS25 datasets. Mount the clones at the `fs25-test` paths above. Do not mount the
live paths into the test container, even read-only, because the GIANTS web files
and configuration are legitimately modified during operation.

## Build and first smoke test

Copy `.env.example` to `.env`, replace every placeholder locally, then run:

```bash
docker compose build --pull fs25-replacement-test
docker compose up -d fs25-replacement-test
docker compose ps
docker compose logs -f --tail=200 fs25-replacement-test
```

Test endpoints use ports that do not collide with the working server:

- VNC: `5901`
- noVNC: `http://TRUENAS-IP:6081/vnc.html?resize=remote&autoconnect=1`
- GIANTS web: `http://TRUENAS-IP:8000`
- Game: TCP/UDP `10824`

The initial empty-path smoke test is expected to report precise missing-game
errors until an installer is supplied. It must still bring up VNC/noVNC without
touching the live server.

## Acceptance checks

1. Container reaches healthy after the relevant services are enabled.
2. A restart does not recursively change ownership of the Wine prefix.
3. `system.reg`, licence files, and the `.fs25-owner` marker survive recreation.
4. Game/config symlinks point to `/opt/fs25/game` and `/opt/fs25/config`.
5. The VNC Webpanel shortcut opens the current container IP automatically.
6. `docker stop -t 120 fs25-replacement-test` allows Wine/FS25 to exit cleanly.
7. The live `arch-fs25server` container remains running and unchanged.

Do not switch production mounts or ports until all checks pass.
