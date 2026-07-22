#!/usr/bin/dumb-init /bin/bash

set -euo pipefail

export USER="${USER:-nobody}"

# CONFIG_PLACEHOLDER

# create env var for display (note display number must match for tigervnc)
export DISPLAY=:0

# vnc start command
vnc_start="Xvnc :0 -depth 24"

# if a password is specified then generate password file in /home/nobody/.vnc/passwd
# else append insecure flag to command line
if [[ -n "${VNC_PASSWORD:-}" ]]; then
	password_length="${#VNC_PASSWORD}"
	if [[ "${password_length}" -gt 5 ]]; then
		echo "[info] Password length OK, proceeding to set password..."
        mkdir -p "$HOME/.vnc" && chmod 700 "$HOME/.vnc"
        printf '%s\n' "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
		vnc_start="${vnc_start} -PasswordFile=${HOME}/.vnc/passwd"
	else
		echo "[warn] Password specified is less than 6 characters and thus will be ignored."
		vnc_start="${vnc_start} -SecurityTypes=None"
	fi
else
	vnc_start="${vnc_start} -SecurityTypes=None"
fi

# if defined then set title for the web ui tab
if [[ -n "${WEBPAGE_TITLE:-}" ]]; then
	vnc_start="${vnc_start} -Desktop='${WEBPAGE_TITLE}'"
fi

# Get the container's IP address, excluding the loopback interface
IP_ADDRESS=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}')

# Check if an IP address was found
if [ -n "$IP_ADDRESS" ]; then
    # Export the IP address as an environment variable
    export CONTAINER_IP="$IP_ADDRESS"
    echo "CONTAINER_IP environment variable set to: $CONTAINER_IP"
else
    echo "No IP address found for the container."
    exit 1
fi

# Remove only stale display :0 state.  The Binhex base owns the parent
# directories, so deleting /tmp/.X* as the nobody user prevents Xvnc from
# starting when strict error handling is enabled.
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0 || true

# Start tigervnc and wait for it to accept connections before launching
# websockify or Xfce.  This avoids the intermittent "Cannot open display"
# failure seen when Xfce races Xvnc during container startup.
eval "${vnc_start}" &
vnc_pid=$!
vnc_ready=false

for _ in $(seq 1 60); do
	if nc -z 127.0.0.1 5900; then
		vnc_ready=true
		break
	fi

	if ! kill -0 "${vnc_pid}" 2>/dev/null; then
		wait "${vnc_pid}" || true
		echo "[error] Xvnc exited before port 5900 became ready."
		exit 1
	fi

	sleep 1
done

if [[ "${vnc_ready}" != "true" ]]; then
	echo "[error] Timed out waiting for Xvnc on port 5900."
	kill "${vnc_pid}" 2>/dev/null || true
	wait "${vnc_pid}" 2>/dev/null || true
	exit 1
fi

echo "[info] Xvnc is ready on port 5900."

# starts novnc (web vnc client) - note also starts websockify to connect novnc to tigervnc server
/usr/sbin/websockify --web /usr/share/webapps/novnc/ 6080 localhost:5900 &

# Launch Xfce in the background.

/usr/local/bin/autostart_fs25.sh &

dbus-launch startxfce4

# STARTCMD_PLACEHOLDER

# run cat in foreground, this prevents start.sh script from exiting and ending all background processes
cat
