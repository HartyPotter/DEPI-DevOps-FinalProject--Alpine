#!/bin/sh

# Generate SSH host keys if they don't exist
ssh-keygen -A

# Ensure the .ssh directory exists and has the correct permissions
mkdir -p /home/jenkins/.ssh
chmod 700 /home/jenkins/.ssh

# Write the public key passed as an environment variable to authorized_keys
echo "$JENKINS_AGENT_SSH_PUBKEY" > /home/jenkins/.ssh/authorized_keys
chmod 600 /home/jenkins/.ssh/authorized_keys

# Ensure the jenkins user owns the .ssh directory
chown -R jenkins:jenkins /home/jenkins/.ssh


# Start SSH daemon in the foreground
exec /usr/sbin/sshd -D