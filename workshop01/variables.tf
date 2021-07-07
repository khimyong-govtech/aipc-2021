variable docker_ip {
    type = string
}

variable docker_host {
    type = string
}

variable docker_cert_path {
    type = string
}

variable "digitalocean_token" {
    type=string
}

variable "dov_tag" {
    type=string
    default="v4"
}


variable "dov_instances" {
    type = list(string)
    default = [ "one", "two", "three" ]
}

variable "public_key" {
    type = string
}

variable "private_key" {
    type = string
}