# Jenkins Docker Host

Run Jenkins in Docker with access to your host's Docker daemon. Works on any platform without messing with group IDs.

## Features

- **Cross-platform** - macOS, Linux, CI runners  
- **Zero configuration** - Detects Docker socket automatically
- **Host Docker access** - No Docker-in-Docker complexity
- **One command setup** - `./start-jenkins.sh` and you're done

## The Problem

Different systems use different group IDs for the Docker socket (macOS uses 20, various Linux distros use 998/999/etc). Hard-coding these breaks portability.

## The Solution

This setup automatically detects your Docker socket's group ID and builds Jenkins accordingly. No manual configuration needed.

## Quick Start

```bash
git clone git@github.com:OzkanSisik/jenkins-docker-host.git
cd jenkins-docker-host
./start-jenkins.sh
```

That's it. Jenkins will be running at http://localhost:8080 with Docker access.

**Default login:** admin / changeme123!

**Custom password:**
```bash
JENKINS_ADMIN_PASSWORD="your_password" ./start-jenkins.sh
```

## Verify It Works

```bash
docker-compose exec jenkins docker ps
```

You should see your host's containers listed.

## How It Works

1. `detect-docker-gid.sh` finds your Docker socket and reads its group ID
2. Dockerfile creates Jenkins with Docker CLI and adds the user to the right group  
3. Jenkins starts with access to your host's Docker daemon

## Persistent Data

Your Jenkins configuration, jobs, and plugins are stored in Docker volumes. They'll survive restarts and rebuilds.

To start completely fresh:
```bash
./scripts/cleanup-jenkins.sh 
./start-jenkins.sh
```

## Notes

- The Docker socket is mounted into Jenkins - anyone with Jenkins access can control Docker
- Admin password can only be set on first run (change it later in Jenkins UI if needed)
- Default password is fine for development, use your own for anything serious

## Security Context

This setup works well for **local development** when you're the only user. The Docker socket access is a common pattern for personal projects and development environments.

**For better security**, you can improve this setup with:

- **Kubernetes with build agents** - isolated build environments
- **Remote Docker daemon** - keep Docker separate from Jenkins  

## Troubleshooting

**Jenkins can't access Docker:**
- Check that Docker is running on your host
- Verify the socket exists: `ls -la /var/run/docker.sock`
- Ensure the container has the right group membership: `docker-compose exec jenkins id`

**Clean slate:**
- Remove everything: `./scripts/cleanup-jenkins.sh`
- Rebuild: `./start-jenkins.sh`
