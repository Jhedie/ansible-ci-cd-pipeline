[webservers]
${public_ip} ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'
