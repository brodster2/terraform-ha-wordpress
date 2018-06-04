# Create the top level web ACL - populate rules later with cloud formation
resource "aws_waf_web_acl" "wordpressWafAcl" {
  name        = "wordpress-waf-acl"
  metric_name = "wordpressWafAcl"

  default_action {
    type = "ALLOW"
  }
}
