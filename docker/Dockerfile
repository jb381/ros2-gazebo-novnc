FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=jazzy
ARG TB3_SIM_REPO=https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

SHELL ["/bin/bash", "-c"]

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_DISTRO=${ROS_DISTRO}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      locales curl ca-certificates gnupg2 lsb-release software-properties-common && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    add-apt-repository universe && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME}) main" \
      > /etc/apt/sources.list.d/ros2.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ros-${ROS_DISTRO}-desktop \
      ros-${ROS_DISTRO}-ros-gz \
      ros-${ROS_DISTRO}-turtlebot3 \
      ros-${ROS_DISTRO}-turtlebot3-simulations \
      build-essential \
      python3-colcon-common-extensions \
      git \
      gosu \
      tini \
      dbus-x11 \
      tigervnc-standalone-server \
      tigervnc-tools \
      novnc \
      websockify \
      supervisor \
      xfce4 \
      xfce4-terminal \
      xfonts-base \
      xauth && \
    rm -rf /var/lib/apt/lists/*

RUN id -u ubuntu >/dev/null 2>&1 || useradd -m -s /bin/bash -u 1000 ubuntu

RUN mkdir -p /home/ubuntu/.vnc /home/ubuntu/.config/xfce4 /opt/turtlebot3_ws/src && \
    echo "ubuntu" | vncpasswd -f > /home/ubuntu/.vnc/passwd && \
    chmod 600 /home/ubuntu/.vnc/passwd && \
    printf '%s\n' \
      '#!/bin/sh' \
      'unset SESSION_MANAGER' \
      'unset DBUS_SESSION_BUS_ADDRESS' \
      'exec dbus-launch --exit-with-session startxfce4' \
      > /home/ubuntu/.vnc/xstartup

RUN chmod +x /home/ubuntu/.vnc/xstartup && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
    git clone --depth 1 -b "${ROS_DISTRO}" "${TB3_SIM_REPO}" /opt/turtlebot3_ws/src/turtlebot3_simulations && \
    /bin/bash -lc "source /opt/ros/${ROS_DISTRO}/setup.bash && cd /opt/turtlebot3_ws && colcon build --symlink-install" && \
    chown -R ubuntu:ubuntu /home/ubuntu /opt/turtlebot3_ws

COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

WORKDIR /opt/turtlebot3_ws
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
