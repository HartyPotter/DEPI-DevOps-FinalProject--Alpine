# DevOps Project: Jenkins Pipeline

We started by building the Jenkins pipeline (attached in the repo). Here is a breakdown of the file:
The Jenkins file started first by defining the environment variables that we will be using. The variables are as follows:
- Docker Hub Username
- Docker Hub Password (After learning about HashiVaults and GitHub Secrets we still hardcode passwords. Somethings are learned the hard way :) )
- App Name
- App Port

Then the file describes the Jenkins pipeline. The pipeline consists of five stages:
1. Building the docker image from the node application
2. Pushing to our DockerHub account
3. Pulling the agent on another Jenkins agent (Jenkins worker)
4. Running the application on the built container on the agent
5. Checking the application works by using the `curl` command on the container

We will discuss the steps taken to achieve these steps. On an ubuntu virtual machine, we created the Jenkins master agent and created a pipeline that is dependent on the GitHub repo main branch. We also created our DockerHub account. We tested the pipeline at this stage (still no agent to pull the image), and it was successfully able to build the image as well as push the image to DockerHub. The next step was to create the Jenkins agent on another VM and pull the image. However, we thought this will be an easy task! We decided to make it a little bit harder. We decided to choose a docker container to represent our Jenkins agent (and here’s how we lost two days of debugging). Issues we ran through:

1. **Connecting to Jenkins agent:**

    We pulled the [Jenkins official image](https://hub.docker.com/r/jenkins/jenkins) and ran the container. We thought that the Jenkins master will be able to reach the Jenkins agent using the container IP address only. After several tries, we came through this [tutorial](https://www.jenkins.io/doc/book/using/using-agents/) which discusses that you don’t actually need Jenkins itself running on the Jenkins agent, you only need the JDK. We downloaded the [Jenkins agent](https://hub.docker.com/r/jenkins/ssh-agent) official image, generated a pair of ssh keys, and ran it with the public key as an environment variable.

2. **SSH Connection problem:**

    The Jenkins master now was able to detect the agent. However, things don’t ever go easy. We ran through multiple “SSH: Connection Refused” issues. We got into multiple tries of checking the pair of keys generated. At first, we had the issue of not including the host part at the end of the SSH public key env variable given to the container. Solving this, the console still outputting “Connection Refused”. We generated and deleted the old keys (multiple times) to ensure the pair of keys used are matching. However, this was not the case and all the key pairs were actually matching. We confirmed this by SSHing the container using the terminal (outside of Jenkins). At this point, we were running crazy. The issue turned out to be that Jenkins doesn’t loop through the SSH keys on the machine. It only tries the [standard SSH key](https://askubuntu.com/questions/4830/easiest-way-to-copy-ssh-keys-to-another-machine), which is the first SSH key generated on the machine (with default settings). After deleting all keys already generated (including all the keys already on the VM), we were able to make Jenkins reach its agent.

3. **Running Docker inside Docker (AKA [DinD](https://hub.docker.com/_/docker)):**


    <p align="center">
      <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPuyfU5OTBD2mIefOd0TxKu5SB9fLhodMgwg&s" alt="Jenkins using Docker"/>
    </p>

   
    Of course, the `docker pull` command won’t run itself on the container. The Jenkins master told us this the hard way (“docker command is not found”) with its devil face. We tried to install docker on the Jenkins agent container but of course, “apt-get is not found”. The image we’re using is based on alpine. After several trials to install `apt`, we finally came across a blog that says alpine has its package manager too `apk`. We installed docker using `apk add docker`. It was fine until we realized that “Cannot reach docker daemon”. We realized that the service is not working. We took the easy way this time and transitioned to another [Jenkins agent image based on Debian](https://hub.docker.com/layers/jenkins/ssh-agent/latest-debian-jdk17/images/sha256-95b2fe5b6a42c924823fc45850c6c1babb38d4db3b4f6c5736b92665d980e256?context=explore). It made our life much easier using `apt-get` and `systemctl` commands. We also realized that `dockerd` is the new “docker daemon” we’re dealing with. Finally, we were able to get the Jenkins agent running docker and pulling the image.
