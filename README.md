# ROS 2 + Gazebo in Docker (noVNC, Apple Silicon)

Run ROS 2 Gazebo simulations in a fully containerized environment and access them through a browser desktop (noVNC). A TurtleBot3 configuration is provided in `.env.example` as a ready-to-use starting point.

![TurtleBot3 Gazebo running in noVNC](screenshot.png)

This repository is optimized for:

- macOS on Apple Silicon (arm64)
- Docker Desktop
- Browser-based desktop at `http://localhost:6080`

## Compatibility

- **Tested:** macOS Apple Silicon + Docker Desktop.
- **Expected to work:** other operating systems with Docker, and Podman setups that support Compose (`podman compose` / `podman-compose`).
- **Note:** this repo pins `platform: linux/arm64` for Apple Silicon. On non-arm64 hosts, adjust that setting if you want native architecture/performance.
- **Podman caveat:** depending on your Podman/rootless setup, you may need to remove `security_opt: seccomp=unconfined`.

## What this provides

- Ubuntu 24.04 + ROS 2 Jazzy
- Gazebo + ROS bridge (`ros_gz`)
- XFCE desktop over noVNC
- Configurable simulation packages and workspace via `.env`

No host ROS installation is required.

A pre-built image with TurtleBot3 is available on [GitHub Container Registry](https://github.com/jb381/ros2-gazebo-novnc/pkgs/container/ros2-gazebo-novnc) for demonstration purposes. Building from source is recommended — it gives you full control over packages, robot configuration, and keeps the image up to date with your changes.

## Prerequisites

- Docker Desktop installed and running
- Apple Silicon Mac recommended

## Quick start

### Option A: Build from source (Recommended)

1. Copy `.env.example` to `.env` and adjust as needed:

   ```bash
   cp .env.example .env
   ```

   The defaults in `.env.example` configure a TurtleBot3 setup. To run a bare ROS 2 + Gazebo environment instead, clear the build settings in `.env`:

   ```bash
   ADDITIONAL_PACKAGES=
   WORKSPACE_REPOS=
   ```

   See [Configuration](#configuration) for all available variables.

2. Build the image. The first build may take a while as it downloads and installs ROS 2, Gazebo, and any additional packages.

   ```bash
   docker compose build
   ```

3. Start the container:

   ```bash
   docker compose up -d
   ```

4. Check status:

   ```bash
   docker compose ps
   ```

5. Open in browser:
   - URL: `http://localhost:6080`
   - VNC password: the value of `VNC_PASSWORD` (default: `ubuntu`)

### Option B: Pre-built image (TurtleBot3)

> For demonstration purposes. Build from source (Option A) is recommended for regular use.

Pull and run without building:

```bash
docker pull ghcr.io/jb381/ros2-gazebo-novnc:latest
```

Create a `.env` file with your runtime settings:

```bash
cp .env.example .env
```

Then create a minimal `docker-compose.override.yml` to use the pre-built image:

```bash
echo 'services:
  gazebo-ros2:
    image: ghcr.io/jb381/ros2-gazebo-novnc:latest
    build: {}' > docker-compose.override.yml
```

Start:

```bash
docker compose up -d
```

## Configuration

All settings are configured via a `.env` file (copy from `.env.example`).

### Runtime settings (no rebuild needed)

| Variable        | Default     | Description               |
| --------------- | ----------- | ------------------------- |
| `VNC_PASSWORD`  | `ubuntu`    | Password for noVNC access |
| `VNC_GEOMETRY`  | `1920x1080` | Desktop resolution        |
| `ROS_DOMAIN_ID` | `30`        | ROS 2 DDS domain ID       |
| `PORT`          | `6080`      | Host port for noVNC       |

### Build settings (require `docker compose build`)

| Variable              | Default     | Description                                                                                                                                            |
| --------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `ADDITIONAL_PACKAGES` | *(empty)*   | Space-separated list of additional apt packages to install                                                                                             |
| `WORKSPACE_REPOS`     | *(empty)*   | Space-separated list of git repositories to clone into the ROS 2 workspace. Append `#branch` to specify a branch. Defaults to `ROS_DISTRO` if omitted. |

> `.env.example` ships with TurtleBot3 values pre-filled as a ready-to-use starting point.

### Using a different robot

Edit the build settings in your `.env` file:

```bash
# Example: use a custom robot setup
ADDITIONAL_PACKAGES=ros-jazzy-my-robot ros-jazzy-my-robot-sim
WORKSPACE_REPOS=https://github.com/my-org/my_robot_simulations.git#main
```

After changing build settings, rebuild:

```bash
docker compose build --no-cache
docker compose up -d
```

## Run simulation (TurtleBot3 example)

Inside the noVNC desktop, open terminal #1 and run:

```bash
export TURTLEBOT3_MODEL=burger
ros2 launch turtlebot3_gazebo empty_world.launch.py
```

Keep terminal #1 running.

Open terminal #2 (also in noVNC) and run teleop:

```bash
export TURTLEBOT3_MODEL=burger
ros2 run turtlebot3_teleop teleop_keyboard
```

## Common commands

View logs:

```bash
docker compose logs --tail=200 gazebo-ros2
```

Stop:

```bash
docker compose down
```

Clean rebuild:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Troubleshooting

### noVNC page shows "Failed to connect to server"

The container likely failed to start VNC/noVNC fully.

```bash
docker compose ps
docker compose logs --tail=200 gazebo-ros2
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Gazebo launches but teleop does nothing

Make sure teleop runs in a second terminal while launch is still active in terminal #1.

Also verify:

```bash
export TURTLEBOT3_MODEL=burger
```

## Notes

- This setup is intentionally minimal to reduce moving parts.
- Direct VNC port exposure is disabled; use noVNC on port `6080`.
- The container includes a health check that verifies noVNC is responding on port 80.
- The container restarts automatically (`unless-stopped`) if it crashes.

## License

MIT License. See `LICENSE`.
