variable "backup_vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "plan_name" {
  description = "Name of the backup plan"
  type        = string
}

variable "rule_name" {
  description = "Name of the backup rule"
  type        = string
}

variable "schedule" {
  description = "Cron schedule expression for backups"
  type        = string
}

variable "cold_storage_after" {
  description = "Days after creation to move to cold storage"
  type        = number
}

variable "delete_after" {
  description = "Days after creation to delete backup"
  type        = number
}
