variable "aws_password" {
  type    = string
  default = "PasswordsAreLame1234"
}

variable "dirks_sns_topic_name" {
  type    = string
  default = "dirks-updates-topic-for-redundancy"
}

variable "create_dead_letter_queue" {
  type    = bool
  default = true #do not change, always needed!!!!
}
