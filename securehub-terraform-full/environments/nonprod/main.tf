locals {
  project = var.project_id
  region  = var.region
}

# Hub VPC
resource "google_compute_network" "hub" {
  name                    = var.hub_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hub_subnet" {
  name          = var.hub_subnet_name
  ip_cidr_range = var.hub_subnet_cidr
  region        = local.region
  network       = google_compute_network.hub.id
}

# Spoke VPC
resource "google_compute_network" "spoke" {
  name                    = var.spoke_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "spoke_subnet" {
  name          = var.spoke_subnet_name
  ip_cidr_range = var.spoke_subnet_cidr
  region        = local.region
  network       = google_compute_network.spoke.id
}

# Peering both ways
resource "google_compute_network_peering" "hub_to_spoke" {
  name         = "peering-hub-to-spoke"
  network      = google_compute_network.hub.self_link
  peer_network = google_compute_network.spoke.self_link
}

resource "google_compute_network_peering" "spoke_to_hub" {
  name         = "peering-spoke-to-hub"
  network      = google_compute_network.spoke.self_link
  peer_network = google_compute_network.hub.self_link
}

# Cloud Router + NAT
resource "google_compute_router" "router" {
  name    = "securehub-router"
  region  = local.region
  network = google_compute_network.hub.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "securehub-nat"
  router                             = google_compute_router.router.name
  region                             = local.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Test VMs
resource "google_compute_instance" "hub_vm" {
  name         = "hub-test-vm"
  machine_type = "e2-micro"
  zone         = "${local.region}-a"

  boot_disk { initialize_params { image = "debian-12" } }

  network_interface {
    subnetwork = google_compute_subnetwork.hub_subnet.id
    access_config {}  # external IP
  }
}

resource "google_compute_instance" "spoke_vm" {
  name         = "spoke-test-vm"
  machine_type = "e2-micro"
  zone         = "${local.region}-a"

  boot_disk { initialize_params { image = "debian-12" } }

  network_interface {
    subnetwork   = google_compute_subnetwork.spoke_subnet.id
    # no external IP
  }
}
