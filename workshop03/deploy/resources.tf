locals {
    cs_image = "code-server-${var.cs_version}"
}

data digitalocean_image code-server-image {
    name = local.cs_image
}

data digitalocean_ssh_key mykey {
    name = "default-key"
}

resource digitalocean_droplet code-server {
    name = local.cs_image
    image = data.digitalocean_image.code-server-image.image
    size = var.droplet_size
    region = var.droplet_region

    ssh_keys = [ data.digitalocean_ssh_key.mykey.fingerprint ]

}

resource "local_file" "inventory_yaml" {
    filename = "inventory.yaml"
    content = templatefile("inventory.yaml.tpl", {
        ipv4_address = digitalocean_droplet.code-server.ipv4_address
        private_key = var.private_key
        cs_password = var.cs_password
        cs_domain = "code-${digitalocean_droplet.code-server.ipv4_address}.nip.io"
    })
}

output cs_domain {
    value = "code-${digitalocean_droplet.code-server.ipv4_address}.nip.io"
}
