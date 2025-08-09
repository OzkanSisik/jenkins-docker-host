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
JENKINS_ADMIN_PASSWORD="your_secure_password" ./start-jenkins.sh
```

That's it. Jenkins will be running at http://localhost:8080 with Docker access.

**⚠️ IMPORTANT: Admin password is required!**
- Jenkins will not start without `JENKINS_ADMIN_PASSWORD`
- Use a strong password for security
- The password cannot be changed later without resetting Jenkins

**Default login:** admin / [your password]

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

## Security Context

This setup works well for **local development** when you're the only user. The Docker socket access is a common pattern for personal projects and development environments.

**For better security**, you can improve this setup with:

- **Kubernetes with build agents** - isolated build environments
- **Remote Docker daemon** - keep Docker separate from Jenkins  

## 🚨 AWS Deployment Security Guide

**⚠️ IMPORTANT: This setup has security risks when deployed to AWS. Follow these basic security measures:**

**🚨 SECURITY WARNING: Malicious actors can use your instance for attacks if compromised. This makes security crucial!**

### 1. **Basic AWS Security**
- **Enable MFA** on your AWS account
- **Use IAM Roles** for EC2 instances (recommended)
- **Enable MFA for IAM users** 
- **Rotate Access Keys** if you must use them

### 2. **EC2 Security Groups**
- **Restrict port 8080** to your IP only:
  ```bash
  # Don't use 0.0.0.0/0 (allows anyone)
  # Use your specific IP instead
  ```

### 3. **Dangerous Mounts - Security vs Functionality**

**⚠️ These mounts are needed for functionality but create security risks:**

```yaml
# These are REQUIRED for local development:
- /var/run/docker.sock:/var/run/docker.sock  # Gives Docker access
- ~/.ssh:/var/jenkins_home/.ssh              # Gives SSH access
```

**Why they're dangerous on AWS:**
- Docker socket gives full host access (can access AWS credentials)
- SSH keys can be used to access other systems


**For AWS deployment, consider alternatives:**

**Instead of Docker socket mount:**
- **Docker-in-Docker (DinD):** Run Docker inside Jenkins container
- **Remote Docker daemon:** Use a separate Docker host
- **Build agents:** Use Jenkins agents with their own Docker

**Instead of SSH keys mount:**
- **Jenkins Credentials Store:** Store SSH keys in Jenkins
- **IAM Roles:** Use AWS IAM roles instead of SSH keys
- **Deploy keys:** Use repository-specific SSH keys

**Practical approach for personal projects:**
- Keep the mounts but restrict access with security groups
- Use strong passwords and MFA
- Monitor for suspicious activity
- Consider this a development setup, not production

### 4. **Use Jenkins Credentials**
- Store AWS keys in Jenkins Credentials Store
- Use IAM Roles for EC2 instances
- Don't hardcode credentials in scripts

**Note:** These are basic security measures. Security is an ongoing process - always stay updated with best practices and monitor for threats.

## Troubleshooting

**Jenkins can't access Docker:**
- Check that Docker is running on your host
- Verify the socket exists: `ls -la /var/run/docker.sock`
- Ensure the container has the right group membership: `docker-compose exec jenkins id`

**Clean slate:**
- Remove everything: `./scripts/cleanup-jenkins.sh`
- Rebuild: `JENKINS_ADMIN_PASSWORD="your_password" ./start-jenkins.sh`
