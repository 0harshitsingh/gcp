terraform {
  backend "gcs" {
    bucket = "terraform-state-securehub"   # update after bucket creation
    prefix = "terraform/state/nonprod"
  }
}
