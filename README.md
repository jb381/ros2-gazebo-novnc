# ROS 2 Jazzy + TurtleBot3 Gazebo in Docker (noVNC, Apple Silicon)

Run TurtleBot3 simulation in a fully containerized ROS 2 Jazzy environment and access it through a browser desktop (noVNC).

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
- TurtleBot3 simulation packages
- Gazebo + ROS bridge (`ros_gz`)
- XFCE desktop over noVNC
- TurtleBot3 simulation workspace cloned and built inside the image

No host ROS installation is required.

## Prerequisites

- Docker Desktop installed and running
- Apple Silicon Mac recommended

## Quick start

Build image:

```bash
docker compose build
```

Start container:

```bash
docker compose up -d
```

Check status:

```bash
docker compose ps
```

Open in browser:

- URL: `http://localhost:6080`
- VNC password: `ubuntu`

## Run simulation

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

## License

MIT License. See `LICENSE`.
