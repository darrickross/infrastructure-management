#!/bin/bash

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
