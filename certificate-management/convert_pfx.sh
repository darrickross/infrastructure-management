#!/bin/bash -e

# TODO:
# - Add support for `quiet`, grab PFX_PASSWORD from env variable

# ------------------------------------------------------------------------------
# Show Help
# ------------------------------------------------------------------------------

show_help() {
  cat <<EOF
Usage: $0 --input/-i <path/to/bundle.pfx> [options]

Required Options:
  -i, --input <path>        Specify the input .pfx file

Optional File Types to extract
  -p, --private             Extract private key             name.$EXT_PRIVATE_KEY
  -P, --public              Extract public key              name.$EXT_PUBLIC_KEY
  -c, --certificate         Extract certificate             name.$EXT_CERTIFICATE
  -C, --chain               Extract full certificate chain  name.$EXT_CHAIN_CERTIFICATE
  -r, --root-ca             Extract root CA certificate     name.$EXT_ROOT_CA_CERTIFICATE

  -s, --standard            Effectively the same as -p -c -C
  -a, --all                 Effectively the same as -p -P -c -C -r

Optional modifiers:
  -o, --output <path>       Specify base name for output files (default to .pfx filename)
  -d, --details             Show details about the .pfx file
  -q, --quiet               Run in quiet mode (NOT IMPLEMENTED)
  -v, --verbose             Run in verbose mode
  -h, --help                Show this help message

Examples:
  $0 -i /path/to/bundle.pfx -p -c -C
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
GREEN='\033[0;32m' # Green
RED='\033[0;31m'   # Red
RESET='\033[0m'    # No Color

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

print_error() {
  echo -e "${RED}ERROR${RESET}: $1"
}

print_color_true_false() {
  if [ "$1" = true ]; then
    echo -e "${GREEN}$1${RESET}"
  elif [ "$1" = false ]; then
    echo -e "${RED}$1${RESET}"
  else
    echo "$1"
  fi
}

print_based_on_log_level() {
  if [ "$log_level" -gt 0 ]; then
    echo "$1"
  fi
}

validate_pfx_file() {
  local pfx_file_path="$1"

  if [ ! -f "$pfx_file_path" ]; then
    print_error "File not found: $pfx_file_path"
    exit 1
  fi

  if ! openssl pkcs12 -in "${pfx_file}" -noout -passin stdin <<<"$PFX_PASSWORD" 2>/dev/null; then
    print_error "Invalid password for $pfx_file_path"
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Parse Command Line Arguments
# ------------------------------------------------------------------------------

# Default Required Arguments
pfx_file=""

# Default Optional File Types to extract arguments
extract_private_key=false
extract_public_key=false
extract_certificate=false
extract_chain_certificate=false
extract_root_certificate=false

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
  -p | --private)
    extract_private_key=true
    shift
    ;;
  -P | --public)
    extract_public_key=true
    shift
    ;;
  -c | --certificate)
    extract_certificate=true
    shift
    ;;
  -C | --chain)
    extract_chain_certificate=true
    shift
    ;;
  -r | --root-ca)
    extract_root_certificate=true
    shift
    ;;

  -s | --standard)
    extract_private_key=true
    extract_certificate=true
    extract_chain_certificate=true
    shift
    ;;
  -a | --all)
    extract_private_key=true
    extract_public_key=true
    extract_certificate=true
    extract_chain_certificate=true
    extract_root_certificate=true
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
    Output base name: $output_name.<EXTENSION>

  Keys to extract:
    - Extract private key:          $(print_color_true_false $extract_private_key)
    - Extract public key:           $(print_color_true_false $extract_public_key)
    - Extract certificate:          $(print_color_true_false $extract_certificate)
    - Extract chain certificate:    $(print_color_true_false $extract_chain_certificate)
    - Extract root CA certificate:  $(print_color_true_false $extract_root_certificate)

  Modifiers:
    - Display details:              $(print_color_true_false $display_details)
    - Log level:                    $log_level

EOF
fi

# ------------------------------------------------------------------------------
# Get password
# ------------------------------------------------------------------------------

# Get the PFX password
# https://unix.stackexchange.com/a/439510
IFS= read -rs -p 'Enter the .pfx password: ' PFX_PASSWORD
echo ''

# ------------------------------------------------------------------------------
# Validate PFX file & password
# ------------------------------------------------------------------------------

validate_pfx_file "$pfx_file"
