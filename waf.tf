# Attach web ACL to Application load balancer
resource "aws_wafregional_web_acl_association" "waf_alb" {
  resource_arn = "${data.wp_lb.arn}"
  web_acl_id   = "${aws_wafregional_web_acl.wordpress_waf_acl.id}"
}

# Create the top level web ACL - populate rules later with cloud formation
resource "aws_wafregional_web_acl" "wordpress_waf_acl" {
  name        = "wordpressWafACL"
  metric_name = "wordpressWafACL"

  default_action {
    # Allow any traffic that doesn't match any rules bellow
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = "${aws_wafregional_rule.sqli_rule.id}"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 2
    rule_id  = "${aws_wafregional_rule.xss_rule.id}"
  }
}

# XXS matchset and rule
resource "aws_wafregional_xss_match_set" "xss_match_set" {
  name = "xss_match_set"

  xss_match_tuple {
    text_transformation = "NONE"

    field_to_match {
      type = "URI"
    }
  }

  xss_match_tuple {
    text_transformation = "NONE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }
}

resource "aws_wafregional_rule" "xss_rule" {
  name        = "xxsWAFRule"
  metric_name = "xxsWAFRule"

  predicate {
    type    = "XssMatch"
    data_id = "${aws_wafregional_xss_match_set.xss_match_set.id}"
    negated = false
  }
}

# SQL injection matchset and rule
resource "aws_wafregional_sql_injection_match_set" "sql_match_set" {
  name = "sql_match_set"

  sql_injection_match_tuple {
    text_transformation = "CMD_LINE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "CMD_LINE"

    field_to_match {
      type = "BODY"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  sql_injection_match_tuple {
    text_transformation = "URL_DECODE"

    field_to_match {
      type = "BODY"
    }
  }
}

resource "aws_wafregional_rule" "sqli_rule" {
  name        = "sqliWAFRule"
  metric_name = "sqliWAFRule"

  predicate {
    type    = "SqlInjectionMatch"
    data_id = "${aws_wafregional_sql_injection_match_set.sql_match_set.id}"
    negated = false
  }
}

# Import data of load balancer to extract alb ARN
data "aws_lb" "wp_lb" {
  name = "${var.load_balancer_name}"
}
