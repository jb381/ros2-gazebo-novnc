#!/usr/bin/env bash
set -euo pipefail

export USER=ubuntu
export HOME=/home/ubuntu
export DISPLAY=:1
export VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"

grep -q "source /opt/ros/${ROS_DISTRO}/setup.bash" "${HOME}/.bashrc" || \
  echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> "${HOME}/.bashrc"
grep -q "source /opt/turtlebot3_ws/install/setup.bash" "${HOME}/.bashrc" || \
  echo "[ -f /opt/turtlebot3_ws/install/setup.bash ] && source /opt/turtlebot3_ws/install/setup.bash" >> "${HOME}/.bashrc"
grep -q "export DISPLAY=:1" "${HOME}/.bashrc" || \
  echo "export DISPLAY=:1" >> "${HOME}/.bashrc"
grep -q "export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST" "${HOME}/.bashrc" || \
  echo "export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST" >> "${HOME}/.bashrc"
grep -q "export ROS_DOMAIN_ID=30" "${HOME}/.bashrc" || \
  echo "export ROS_DOMAIN_ID=30" >> "${HOME}/.bashrc"

cat > "${HOME}/.vnc/vnc_run.sh" <<EOF
#!/bin/sh
if [ -e /tmp/.X1-lock ]; then
  rm -f /tmp/.X1-lock
fi
if [ -e /tmp/.X11-unix/X1 ]; then
  rm -f /tmp/.X11-unix/X1
fi
vncserver :1 -fg -geometry ${VNC_GEOMETRY} -depth 24
EOF

chmod +x "${HOME}/.vnc/vnc_run.sh"
chown -R ubuntu:ubuntu "${HOME}"

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
