output "state_bucket_name" {
  value = try(module.state_bucket.state-bucket-name, "")
  # Multiple workspace setup:
  # value = try(module.state_bucket[0].state-bucket-name, "")
}

output "project_id" {
  value = try(google_project.project.project_id, "")
}

output "project_number" {
  value = try(google_project.project.number, "")
}
