FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=jazzy
ARG ADDITIONAL_PACKAGES=""
ARG WORKSPACE_REPOS=""
ARG BUILD_DATE
ARG VCS_REF

LABEL org.opencontainers.image.title="ROS 2 + Gazebo (noVNC)" \
      org.opencontainers.image.description="ROS 2 Gazebo simulation in a containerized environment with browser-based noVNC desktop" \
      org.opencontainers.image.source="https://github.com/jb381/ros2-gazebo-novnc" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}"

SHELL ["/bin/bash", "-c"]

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ROS_DISTRO=${ROS_DISTRO}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      locales curl ca-certificates gnupg2 lsb-release software-properties-common && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    add-apt-repository universe && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME}) main" \
      > /etc/apt/sources.list.d/ros2.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      ros-${ROS_DISTRO}-desktop \
      ros-${ROS_DISTRO}-ros-gz \
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
      xauth \
      ${ADDITIONAL_PACKAGES} && \
    rm -rf /var/lib/apt/lists/*

RUN id -u ubuntu >/dev/null 2>&1 || useradd -m -s /bin/bash -u 1000 ubuntu

RUN mkdir -p /home/ubuntu/.vnc /home/ubuntu/.config/xfce4 /opt/ros2_ws/src && \
    printf '%s\n' \
      '#!/bin/sh' \
      'unset SESSION_MANAGER' \
      'unset DBUS_SESSION_BUS_ADDRESS' \
      'exec dbus-launch --exit-with-session startxfce4' \
      > /home/ubuntu/.vnc/xstartup && \
    chmod +x /home/ubuntu/.vnc/xstartup && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html && \
    if [ -n "${WORKSPACE_REPOS}" ]; then \
      for repo in ${WORKSPACE_REPOS}; do \
        branch="${ROS_DISTRO}" && \
        case "${repo}" in \
          *#*) branch="${repo##*#}"; repo="${repo%#*}";; \
        esac && \
        repo_name=$(basename "${repo}" .git) && \
        clone_dir="/opt/ros2_ws/src/${repo_name}" && \
        if [ -d "${clone_dir}" ]; then \
          clone_dir="${clone_dir}-$(echo "${repo}" | md5sum | cut -c1-8)"; \
        fi && \
        git clone --depth 1 -b "${branch}" "${repo}" "${clone_dir}"; \
      done && \
      /bin/bash -lc "source /opt/ros/${ROS_DISTRO}/setup.bash && cd /opt/ros2_ws && colcon build --symlink-install"; \
    fi && \
    chown -R ubuntu:ubuntu /home/ubuntu /opt/ros2_ws

COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

WORKDIR /opt/ros2_ws
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
