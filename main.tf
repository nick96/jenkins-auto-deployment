variable "do_token" {}
variable "ssh_pub_key_path" {}
variable "jenkins_domain" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "jenkins_host_sshkey" {
  name       = "Jenkins Host SSH Key"
  public_key = "${file("${var.ssh_pub_key_path}")}"
}

resource "digitalocean_droplet" "jenkins_host" {
  name     = "jenkins"
  size     = "s-1vcpu-1gb"
  image    = "coreos-stable"
  region   = "sgp1"
  ssh_keys = ["${digitalocean_ssh_key.jenkins_host_sshkey.fingerprint}"]
}

resource "digitalocean_firewall" "jenkins_host" {
  name = "only-22-and-443"

  droplet_ids = [
    "${digitalocean_droplet.jenkins_host.id}",
  ]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "icmp"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_domain" "jenkins_domain" {
  name       = "${var.jenkins_domain}"
  ip_address = "${digitalocean_droplet.jenkins_host.ipv4_address}"
}

data "template_file" "ansible_hosts" {
  template = "${file("${path.module}/hosts.tpl")}"

  vars = {
    jenkins_domain = "${var.jenkins_domain}"
  }
}

resource "local_file" "ansible_hosts" {
  content  = "${data.template_file.ansible_hosts.rendered}"
  filename = "${path.module}/hosts"
}

output "ipv4" {
  value = "${digitalocean_droplet.jenkins_host.ipv4_address}"
}
