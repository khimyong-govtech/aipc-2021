resource docker_image img_bear {
    name = "chukmunnlee/dov-bear:${var.dov_tag}"
}

resource "digitalocean_ssh_key" "default-key" {
    name = "default-key"
    public_key = file(var.public_key)
}


resource "digitalocean_droplet" "web" {
    image  = "ubuntu-20-04-x64"
    name   = "web"
    region = "sgp1"
    size   = "s-1vcpu-1gb"
    ssh_keys = [digitalocean_ssh_key.default-key.fingerprint]

    connection {
        type = "ssh"
        user = "root"
        private_key = file(var.private_key)
        host = self.ipv4_address
    }

    provisioner "remote-exec" {
        inline = [
            "apt update -y",
            "apt upgrade -y",
            "apt install nginx -y",
            "systemctl enable nginx",
            "systemctl start nginx",
        ]      
    }

    provisioner file {
        source = "./nginx.conf"
        destination = "/etc/nginx/nginx.conf"
    }
    
    provisioner "remote-exec" {
        inline = [
            "/usr/sbin/nginx -s reload"
        ]
    }
}


locals {
    ext_ports = [ for c in docker_container.cont_bear: "${var.docker_ip}:${c.ports[0].external}"]
}

resource docker_container cont_bear {
    count = length(var.dov_instances)
    name = "dov-${count.index}"
    image = docker_image.img_bear.latest

    ports {
        internal = 3000
    }

    env = [
        "INSTANCE_NAME=dov-${var.dov_instances[count.index]}"
    ]
}

resource "local_file" "external_ports" {
    filename = "external_ports.txt"
    content = templatefile("./external_ports.tpl", {
        ports = local.ext_ports
    })
}

resource "local_file" "nginx_conf" {
    filename = "nginx.conf"
    content = templatefile("./nginx.tpl", {
        ports = local.ext_ports
    })
}

resource "local_file" "root_web_file" {
    filename = "root@${digitalocean_droplet.web.ipv4_address}"
}

/*output "image_name" {
    value = docker_container.cont_bear[*].name
}*/

output "image_ports" {
    value = local.ext_ports
}

output "web_ip" {
    value = digitalocean_droplet.web.ipv4_address
}
