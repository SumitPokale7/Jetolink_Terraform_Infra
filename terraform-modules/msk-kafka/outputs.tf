output "zookeeper_connect_string_tls" {
  value = aws_msk_cluster.this.zookeeper_connect_string_tls
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}
