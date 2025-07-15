# Jenkins Docker Host

Run Jenkins in Docker while giving it access to your host's Docker daemon. This setup works across different operating systems without manual configuration.

## What This Solves

Running Jenkins in Docker is great, but getting it to talk to Docker on the host can be tricky. Different systems use different group IDs for the Docker socket:
- macOS: usually group ID 20 (staff)
- Linux: varies by distribution (often 998, 999, or others)
- CI environments: who knows?

This project automatically figures out the right group ID and configures Jenkins accordingly.

## Features

- **Cross-platform**: Works on macOS, Linux, and CI runners without changes
- **Automatic detection**: Finds your Docker socket's group ID at runtime
- **No Docker-in-Docker**: Uses the host's Docker daemon directly
- **Simple startup**: One command gets everything running

## Getting Started

1. **Clone and enter the directory:**
   ```bash
   git clone git@github.com:OzkanSisik/jenkins-docker-host.git
   cd jenkins-docker-host
   ```

2. **Start Jenkins:**
   ```bash
   ./start-jenkins.sh
   ```
   
   This script will:
   - Detect your Docker socket's group ID
   - Build a custom Jenkins image with the right permissions
   - Start Jenkins with Docker access

3. **Verify it's working:**
   ```bash
   docker-compose exec jenkins docker ps
   ```
   
   If you see a list of containers, Jenkins can access Docker!

4. **Open Jenkins:**
   Navigate to [http://localhost:8080](http://localhost:8080) in your browser.

## How It Works

The setup uses three main components:

- **`detect-docker-gid.sh`**: Scans common Docker socket locations and extracts the group ID
- **`Dockerfile`**: Builds Jenkins with Docker CLI and adds the user to the correct group
- **`start-jenkins.sh`**: Orchestrates the whole process

## Security Considerations

⚠️ **Important**: This setup mounts the Docker socket into the Jenkins container. This means:
- Jenkins can control Docker on your host
- Anyone with Jenkins access can run Docker commands
- Consider this when setting up authentication and access controls

On some systems, the Docker socket might be world-writable. For production use, you may want to restrict permissions further.

## Customization

- **Initial setup**: Add Groovy scripts to `init.groovy.d/` for automated Jenkins configuration
- **Persistent data**: Jenkins data is stored in named volumes and will persist between restarts

## Troubleshooting

**Jenkins can't access Docker:**
- Check that Docker is running on your host
- Verify the socket exists: `ls -la /var/run/docker.sock`
- Ensure the container has the right group membership: `docker-compose exec jenkins id`

**Clean slate:**
- Remove everything: `docker-compose down -v --rmi local`
- Rebuild: `./start-jenkins.sh`
