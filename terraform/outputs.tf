 
 

# resource "local_file" "ansible_inventory" {
#   content = templatefile("../ansible-playbooks/hosts.tmpl",
#     {
#      app_servers = digitalocean_droplet.web.*.ipv4_address, 
#      database_server = digitalocean_droplet.database.*.ipv4_address, 
#      mail_server = digitalocean_droplet.mail_server.*.ipv4_address, 
#      staging_server = aws_instance.staging[*].public_ip, # aws_instance.staging.*.public_ip , 
#     }
#   )
#   filename = "../ansible-playbooks/hosts.temp"
# }


# output "load_balancer_dns" {
#   value = aws_lb.main.dns_name
# }

# output "elastic_ip" {
#   value = aws_eip.load_balancer.public_ip
# }

output "staging_dns_name" {
  value = "03i.co"
}

# output "subnet_ids" {
#   value = aws_subnet.subnet_a.*.id  # Replace with your actual resource
# }



# output "name_servers" {
#   value = aws_route53_zone.main.name_servers
# }
