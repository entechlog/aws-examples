#!/bin/bash

# Snowflake RSA Key Generator for AWS Firehose (Clean Version)
set -e

ENCRYPTED=false
PASSPHRASE=""

# Handle command-line args
while [[ $# -gt 0 ]]; do
  case $1 in
    --encrypted|-e)
      ENCRYPTED=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--encrypted|-e]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🔐 Snowflake RSA Key Generator for AWS Firehose"
echo "==============================================="

# Check existing keys
if [[ -f "snowflake_key.p8" || -f "snowflake_key.pub" ]]; then
  read -p "⚠️  Existing key files found. Overwrite? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
  fi
  rm -f snowflake_key.p8 snowflake_key.pub
  echo "✅ Old keys removed"
fi

# Generate key
if [[ "$ENCRYPTED" == true ]]; then
  echo "🔒 Generating encrypted private key..."
  while true; do
    read -s -p "Enter passphrase (min 4 chars): " PASSPHRASE; echo
    read -s -p "Confirm passphrase: " CONFIRM; echo
    [[ ${#PASSPHRASE} -lt 4 ]] && echo "❌ Too short" && continue
    [[ "$PASSPHRASE" != "$CONFIRM" ]] && echo "❌ Mismatch" && continue
    break
  done
  openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -passout pass:"$PASSPHRASE"
else
  echo "🔓 Generating unencrypted private key..."
  openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt
fi

# Generate public key
echo "📄 Generating public key..."
if [[ "$ENCRYPTED" == true ]]; then
  openssl rsa -in snowflake_key.p8 -passin pass:"$PASSPHRASE" -pubout -out snowflake_key.pub
else
  openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub
fi

chmod 600 snowflake_key.p8
chmod 644 snowflake_key.pub

# Extract base64 from private key (PEM stripped method)
echo ""
echo "📦 Extracting private key in base64 format..."

BASE64_KEY=$(grep -v "BEGIN.*PRIVATE KEY" snowflake_key.p8 | grep -v "END.*PRIVATE KEY" | tr -d '\n' | tr -d ' ')

echo "🧪 Base64 Validation (AWS Firehose compatibility)"
AWS_REGEX='^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$'

echo "🔹 PEM stripped base64:"
echo "   Length: ${#BASE64_KEY}"
echo "   Regex match: $(echo "$BASE64_KEY" | grep -qE "$AWS_REGEX" && echo "✅" || echo "❌")"
echo "   Decodable: $(echo "$BASE64_KEY" | base64 -d >/dev/null 2>&1 && echo "✅" || echo "❌")"

# Format public key for Snowflake SQL
PUBLIC_KEY=$(grep -v "PUBLIC KEY" snowflake_key.pub | tr -d '\n')

# Extract full PEM content with escaped newlines for Snowflake Terraform provider
PEM_KEY_ESCAPED=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' snowflake_key.p8)

echo ""
echo "✅ Keys generated and validated"

# Output for Snowflake
echo ""
echo "📤 Snowflake SQL Command:"
echo "ALTER USER <your_user> SET RSA_PUBLIC_KEY='$PUBLIC_KEY';"

# Output for AWS Firehose (base64 format)
echo ""
echo "📥 terraform.tfvars entry (AWS Firehose):"
echo "snowflake_private_key = \"$BASE64_KEY\""

# Output for Snowflake Terraform Provider (full PEM format)
echo ""
echo "🏔️  terraform.tfvars entry (Snowflake Provider):"
echo "snowflake_private_key_pem = \"$PEM_KEY_ESCAPED\""

# Passphrase output
if [[ "$ENCRYPTED" == true ]]; then
  echo "snowflake_private_key_passphrase = \"$PASSPHRASE\""
else
  echo "snowflake_private_key_passphrase = \"\""
fi

# Final summary
echo ""
echo "📁 Files generated:"
echo "  - snowflake_key.p8  (private key)"
echo "  - snowflake_key.pub (public key)"
echo ""
echo "🔑 Two key formats generated:"
echo "  - snowflake_private_key     (base64 for AWS Firehose)"
echo "  - snowflake_private_key_pem (full PEM for Snowflake Provider)"
echo ""
echo "🚫 Do NOT commit these files to version control!"
echo "🔐 Keep your private key safe!"