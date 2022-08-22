output "msk_bootstrap_brokers_tls" {
  value       = module.msk.bootstrap_brokers_tls
  description = "MSK TLS connection host:port pairs"
}

output "msk_bootstrap_brokers_sasl_scram" {
  value       = module.msk.bootstrap_brokers_sasl_scram
  description = "MSK SASL SCRAM connection host:port pairs"
}
