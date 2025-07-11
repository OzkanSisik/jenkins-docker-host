# Jenkins Docker Host

A portable, cross-platform Jenkins setup that allows Jenkins (running in Docker) to access the host's Docker daemon securely and reliably on macOS, Linux, and CI environments.

## Features
- **Portable:** Works on macOS, Linux laptops, and cloud CI runners.
- **No hardcoded GIDs:** Automatically detects the Docker socket group ID and configures Jenkins accordingly.
- **No DinD:** Uses the host's Docker daemon for builds and jobs.
- **Easy setup:** One command to detect, build, and launch Jenkins.

## Quick Start

1. **Clone the repo:**
   ```bash
   git clone git@github.com:OzkanSisik/jenkins-docker-host.git
   cd jenkins-docker-host
   ```

2. **Make scripts executable (if needed):**
   ```bash
   chmod +x detect-docker-gid.sh start-jenkins.sh
   ```

3. **Start Jenkins:**
   ```bash
   ./start-jenkins.sh
   ```

4. **Verify Docker access:**
   ```bash
   docker-compose exec jenkins docker ps
   ```
   You should see a list of containers from your host.

5. **Access Jenkins:**
   Open [http://localhost:8080](http://localhost:8080) in your browser.

## How it works
- `detect-docker-gid.sh` finds the GID of your Docker socket and writes it to `.env`.
- The Dockerfile builds Jenkins with Docker CLI and Compose, and ensures the Jenkins user is in the correct group.
- `start-jenkins.sh` automates detection, build, and startup.

## Security Notes
- The Docker socket is mounted into the Jenkins container. Anyone with access to Jenkins can control Docker on the host.
- On some systems, the socket may be world-writable. For stricter security, adjust permissions and group membership as needed.

## Customization
- Edit `docker-compose.yml` to add plugins, volumes, or change ports.
- Add your own Groovy scripts to `init.groovy.d/` for Jenkins bootstrapping.

## License
MIT (see LICENSE) 