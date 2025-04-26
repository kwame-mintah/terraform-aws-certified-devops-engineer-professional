variable "codestarconnections_connection_arn" {
  description = <<-EOF
    The connection ARN that is configured and authenticated for the source provider.
    
EOF

  type = string
}

variable "tags" {
  description = <<-EOF
    Tags to be added to resources created.
    
EOF

  type    = map(string)
  default = {}
}