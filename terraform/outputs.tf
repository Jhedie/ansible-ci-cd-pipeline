output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "ansible_inventory" {
  description = "Ansible inventory content"
  value = templatefile("${path.module}/templates/inventory.tpl", {
    public_ip = module.ec2_instance.public_ip
  })
}
