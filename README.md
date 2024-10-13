# DevOps Project: Jenkins Pipeline

We started by building the Jenkins pipeline (attached in the repo). Here is a breakdown of the file:

The Jenkinsfile begins by defining the environment variables that we will be using. The variables are as follows:
- Docker Hub Username
- Docker Hub Password (After learning about HashiVaults and GitHub Secrets, we still hardcoded passwords. Some lessons are learned the hard way :) )
- App Name
- App Port

Then, the file describes the Jenkins pipeline. The pipeline consists of five stages:
1. Building the Docker image from the Node application
2. Pushing the image to our DockerHub account
3. Pulling the image on another Jenkins agent (Jenkins worker)
4. Running the application in the built container on the agent
5. Verifying the application works by using the `curl` command on the container

### Steps Taken

On an Ubuntu virtual machine, we created the Jenkins master agent and set up a pipeline that is dependent on the GitHub repo's main branch. We also created our DockerHub account. We tested the pipeline at this stage (still no agent to pull the image), and it successfully built the image and pushed it to DockerHub.

The next step was to create the Jenkins agent on another VM and pull the image. However, we thought this would be an easy task! We decided to make it a little harder by choosing a Docker container to represent our Jenkins agent (and here's how we lost two days debugging). Here are the issues we encountered:

1. **Connecting to Jenkins agent**:  
   We pulled the official Jenkins image and ran the container, assuming the Jenkins master could reach the Jenkins agent using just the container's IP address. After several attempts, we found a tutorial explaining that Jenkins doesn't actually need to run on the agent. Only the JDK is required. We downloaded the official Jenkins agent image, generated a pair of SSH keys, and ran the container with the public key as an environment variable.

2. **SSH Connection Problem**:  
   The Jenkins master was now able to detect the agent, but we faced multiple "SSH: Connection Refused" issues. After multiple key pair checks, the issue was traced to not including the host part in the SSH public key environment variable passed to the container. Once we fixed that, "Connection Refused" persisted. After generating and deleting old keys several times, we ensured the pairs matched. The problem was Jenkins only uses the first SSH key generated on the machine by default. After deleting all keys (including those on the VM), Jenkins was able to connect to its agent.

3. **Running Docker inside Docker (DinD)**:  
   The `docker pull` command didn't work inside the container. Jenkins returned the error "docker command not found." The issue stemmed from using an Alpine-based image. After attempts to install `apt`, we discovered that Alpine uses its package manager, `apk`. We installed Docker using `apk add docker`, but then faced a "Cannot reach docker daemon" error, as the service wasn't running. This time, we switched to a Debian-based Jenkins agent image, which made installing Docker and managing the daemon (`dockerd`) much easier. Finally, we got the Jenkins agent to run Docker and pull the image.
