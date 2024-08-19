#!/bin/bash -e

# ------------------------------------------------------------------------------
# Show Help
# ------------------------------------------------------------------------------

show_help() {
  cat <<EOF
Usage: $0 --input/-i <path/to/bundle.pfx> [options]

Required Options:
  -i, --input <path>        Specify the input .pfx file

Optional File Types to extract
  -k, --key                 Extract private key             name.$EXT_PRIVATE_KEY
  -p, --pub                 Extract public key              name.$EXT_PUBLIC_KEY
  -c, --cert                Extract certificate             name.$EXT_CERTIFICATE
  -C, --chain               Extract full certificate chain  name.$EXT_CHAIN_CERTIFICATE
  -r, --root-ca             Extract root CA certificate     name.$EXT_ROOT_CA_CERTIFICATE

  -s, --standard            Effectively the same as -k -c -C
  -a, --all                 Effectively the same as -k -p -c -C -r

Optional modifiers:
  -o, --output <path>       Specify base name for output files (default to .pfx filename)
  -d, --details             Show details about the .pfx file
  -q, --quiet               Run in quiet mode
  -v, --verbose             Run in verbose mode
  -h, --help                Show this help message

Examples:
  $0 -i /path/to/bundle.pfx -k -c -C
    The following will be created:
      - private key:          /path/to/bundle.$EXT_PRIVATE_KEY
      - client certificate:   /path/to/bundle.$EXT_CERTIFICATE
      - chain certificate:    /path/to/bundle.$EXT_CHAIN_CERTIFICATE

  $0 -i bundle.pfx -a -o /path/to/output
    The following will be created:
      - private key:          /path/to/output.$EXT_PRIVATE_KEY
      - public key:           /path/to/output.$EXT_PUBLIC_KEY
      - client certificate:   /path/to/output.$EXT_CERTIFICATE
      - chain certificate:    /path/to/output.$EXT_CHAIN_CERTIFICATE
      - root CA certificate:  /path/to/output.$EXT_ROOT_CA_CERTIFICATE

  $0 -i /path/to/bundle.pfx -d
    Show details about the .pfx file, no additional files will be created

EOF
}

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# Default File Extensions
EXT_PRIVATE_KEY="key"
EXT_PUBLIC_KEY="pub"
EXT_CERTIFICATE="crt"
EXT_CHAIN_CERTIFICATE="chain.crt"
EXT_ROOT_CA_CERTIFICATE="root.crt"

# ANSI escape codes
RED='\033[0;31m' # Red
RESET='\033[0m'  # No Color

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

print_error() {
  echo -e "${RED}ERROR${RESET}: $1"
}

# ------------------------------------------------------------------------------
# Parse Command Line Arguments
# ------------------------------------------------------------------------------

# Default Required Arguments
pfx_file=""

# Default Optional File Types to extract arguments
extract_key=false
extract_pub=false
extract_cert=false
extract_chain=false
extract_root_ca=false

# Default Optional modifiers arguments
output_name=""
display_details=false
log_level=1

while [[ "$#" -gt 0 ]]; do
  case "$1" in
  # Required Options
  -i | --input)
    pfx_file="$2"
    shift 2
    ;;

  # Optional File Types to extract
  -k | --key)
    extract_key=true
    shift
    ;;
  -p | --pub)
    extract_pub=true
    shift
    ;;
  -C | --cert)
    extract_cert=true
    shift
    ;;
  -c | --chain)
    extract_chain=true
    shift
    ;;
  -r | --root-ca)
    extract_root_ca=true
    shift
    ;;

  -s | --standard)
    extract_key=true
    extract_cert=true
    extract_chain=true
    shift
    ;;
  -a | --all)
    extract_key=true
    extract_pub=true
    extract_cert=true
    extract_chain=true
    extract_root_ca=true
    shift
    ;;

  # Optional modifiers
  -o | --output)
    output_name="$2"
    shift 2
    ;;
  -d | --details)
    display_details=true
    shift
    ;;
  -q | --quiet)
    log_level=0
    shift
    ;;
  -v | --verbose)
    log_level=2
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    show_help
    print_error "Unknown option: $1"
    exit 1
    ;;
  esac
done

# ------------------------------------------------------------------------------
# Post arugments parsing
# ------------------------------------------------------------------------------

if [ -z "$output_name" ]; then
  output_name=./$(basename "$pfx_file" .pfx)
fi

# ------------------------------------------------------------------------------
# Validate arugments
# ------------------------------------------------------------------------------

if [ -z "$pfx_file" ]; then
  show_help
  print_error "Missing required argument: --input/-i"
  exit 1
fi

if [ ! -f "$pfx_file" ]; then
  print_error "File not found: $pfx_file"
  exit 1
fi

# ------------------------------------------------------------------------------
# Print Selected Options
# ------------------------------------------------------------------------------

if [ "$log_level" -gt 0 ]; then
  cat <<EOF
  Selected Options:
    Input .pfx file:  $pfx_file
    Output base name: $output_name

  Keys to extract:
    - Extract private key:          $extract_key
    - Extract public key:           $extract_pub
    - Extract certificate:          $extract_cert
    - Extract chain certificate:    $extract_chain
    - Extract root CA certificate:  $extract_root_ca

  Modifiers:
    - Display details: $display_details
    - Log level:       $log_level
EOF
fi
