# The Alpine Journey

As a perfectionist (Please, HELP!), I noticed that the Jenkins agent image based on Alpine took up nearly 800 MB of space and required 15 minutes of build time. Naturally, I took it as a challenge to make the agent work on an Alpine image, reducing the image size to just 130 MB and the build time to under 3 minutes!

The plan was similar to the original approach: create a Jenkins controller (master agent) to handle the Docker image building and an additional Jenkins agent with Docker installed. This would allow the master agent to delegate the work of pulling the image and starting the application to the agent.

Now, let's dive into the challenges grab your popcorn and favorite drink because this will take a while.

## Challenges

Most of these challenges were caused by redoing much of the work that the original image should have handled. The original image of `ssh-agent` handled setting up SSH for the agent which I had to redo when I built a new image.

### 1. SSH Connection and Daemon Process

One of the first problems was getting the Jenkins controller to connect to the Docker agent. After resolving some initial issues related to missing parts of the SSH key, I encountered additional problems with the Alpine SSH agent image:

- **Connection reset by peer:**  
  This was caused by the container exiting immediately due to the main process failing or no entry point being executed.  
  **Solution:** Setting up SSH and manually running the SSH daemon in the Dockerfile entry point using `docker_entrypoint.sh`.  
  **Ref:**  
  - [Stack Overflow #1](https://stackoverflow.com/questions/35690954/running-openssh-in-an-alpine-docker-container)  
  - [Stack Overflow #2](https://stackoverflow.com/questions/69394001/how-can-i-fix-kex-exchange-identification-read-connection-reset-by-peer)
  - [code-exited-1](https://forums.docker.com/t/code-exited-1-error/51317)

- **No Host Keys Found:**  
  When I overwrote the original SSH agent image, the host keys for the SSH server (Jenkins agent) were not being generated. When the Jenkins controller attempted to connect, it couldn’t find any host keys, causing the connection to fail.  
  **Solution:** Generated SSH host keys during the Docker build step using `ssh-keygen -A`.  
  **Ref:**  
  - [Unix Stack Exchange](https://unix.stackexchange.com/questions/642824/ssh-fails-to-start-due-to-missing-host-keys)  
  - [Stack Overflow #3](https://stackoverflow.com/questions/74040682/why-docker-doesnt-see-the-hostkeys-sshd-no-hostkeys-available-exiting)

- **ERROR: Server rejected the private key(s) for user:**  
  This occurred because the SSH private key was generated in the wrong format and type.  
  **Solution:** Used RSA instead of ed25519 and ensured the key was in PEM format, as Jenkins expected.  
  **Ref:**  
  - [Thie nodeis](https://stackoverflow.com/questions/31044704/this-node-is-offline-because-jenkins-failed-to-launch-the-slave-agent-on-it)

With SSH keys successfully generated, we moved on to Docker-related challenges.

### 2. Docker

I initially intended to run a full Docker daemon in the container but encountered many connection and process issues. In the end, I decided to install only the Docker CLI and bind the host’s Docker socket to the container.

This isn't the ideal solution for a few reasons:
- **Dependency on host Docker:** This setup requires Docker to be running on the host, which isn’t always guaranteed.
- **Security concerns:** The Jenkins user in the container would have root privileges on the host, which is not the most secure approach.

Despite resolving several permission issues, Docker still didn’t work properly. The problem stemmed from the mismatch between the container's Docker group ID and the host's Docker group ID. For users in the container to interact with the Docker process on the host, their group IDs need to match.

**Solution:** I manually matched the group IDs, though there’s probably a better solution involving Docker’s user namespaces, which handle user and group ID mapping. However, it didn’t seem worth pursuing further at this point.

**Ref:**  
- [Mounting docker socket as volume in docker container with correct group](https://stackoverflow.com/questions/36185035/how-to-mount-docker-socket-as-volume-in-docker-container-with-correct-group)

### Conclusion

While this journey was challenging, it was a valuable learning experience. I gained a deeper understanding of SSH, building Dockerfiles, working with the Alpine environment, and managing Jenkins agents.
