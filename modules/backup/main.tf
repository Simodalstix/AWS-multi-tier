resource "aws_backup_vault" "this" {
  name = var.backup_vault_name
}

resource "aws_backup_plan" "this" {
  name = var.plan_name

  rule {
    rule_name         = var.rule_name
    target_vault_name = aws_backup_vault.this.name
    schedule          = var.schedule

    lifecycle {
      cold_storage_after = var.cold_storage_after
      delete_after       = var.delete_after
    }

  }
}
