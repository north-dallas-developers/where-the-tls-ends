variable "bucket" {
  description = "Name of bucket"
  type        = string
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags"
}

variable "versioning_enabled" {
  type        = bool
  description = "Should versioning be Enabled (true) or Suspended (false). Default is true"
  default     = true
}

variable "policy" {
  description = "Policy for the bucket"
  default     = null
}

variable "kms_master_key_id" {
  description = "KMS key id if supplied"
  default     = null
}

variable "use_s3_kms" {
  type        = bool
  description = "Use default S3 KMS key"
  default     = false
}
