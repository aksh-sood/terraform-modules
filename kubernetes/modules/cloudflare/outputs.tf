output "domains" {
  value=cloudflare_record.cnames[*].hostname
}