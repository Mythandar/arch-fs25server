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

The SSD-backed test dataset is mounted at `/config`, not at
`/home/nobody/.fs25server`. Binhex persists the complete home under
`/config/home` and links it into `/home/nobody` during initialization. A direct
nested Wine-prefix mount can hide `.build/fs25` and cause an exit-code-2 restart
loop.

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
- Game: host TCP/UDP `10824` forwarded to the server's preserved internal port
  `10823`

The initial empty-path smoke test is expected to report precise missing-game
errors until an installer is supplied. It must still bring up VNC/noVNC without
touching the live server.

## Acceptance checks

1. Container reaches healthy after the relevant services are enabled.
2. A restart does not recursively change ownership of the Wine prefix.
3. `/config/home/.fs25server/system.reg`, licence files, and
   `/config/home/.fs25-owner` survive recreation.
4. Game/config symlinks point to `/opt/fs25/game` and `/opt/fs25/config`.
5. Supervisor reports `fs25-loopback` running after GIANTS starts, exactly one
   process listens on `127.0.0.1:7999`, and the VNC Webpanel shortcut opens the
   localhost URL.
6. `docker stop -t 120 fs25-replacement-test` allows Wine/FS25 to exit cleanly.
7. The live `arch-fs25server` container remains running and unchanged.

Do not switch production mounts or ports until all checks pass.

The eventual production mount must be:

```yaml
- /mnt/JailHouse/VirtualMachines/FS25:/config
```

Never use `/mnt/JailHouse/VirtualMachines/FS25:/home/nobody/.fs25server`.

## TrueNAS Apps GUI cutover

Install `docker-compose.truenas-test.yml` through the TrueNAS Custom App YAML
editor for the isolated test. It pulls the published image and uses only the
test container, ports, and datasets documented above.

After that test passes, use `docker-compose.truenas.yml` for cutover. Stop the
existing app before installing the replacement because the production template
deliberately reuses its container name, ports, and datasets. Replace the image's
`main` tag with the tested immutable `sha-<commit>` tag before considering the
deployment final.
