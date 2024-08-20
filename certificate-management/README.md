# certificate-management

## Relative Folder Structure

- [*root directory*](../README.md)
  - [/certificate-management](./README.md) - ***YOU ARE HERE***
    - [`convert_pfx.sh`](#convert_pfxsh) - Script for managing and extracting components from a `.pfx` (PKCS12) bundle

## Directory Goals

The `certificate-management` folder contains scripts designed to manage certificates and cryptographic components. These tools aim to simplify the extraction and handling of private keys, public keys, certificates, and certificate chains from bundled `.pfx` files.

## `convert_pfx.sh`

### `convert_pfx.sh` Overview

`convert_pfx.sh` is a Bash script designed to extract various cryptographic components such as private keys, public keys, certificates, chain certificates, and root CA certificates from a `.pfx` file. It can also display details about the `.pfx` file without performing any extraction.

### `convert_pfx.sh` Requirements

- `openssl`: This script relies on OpenSSL for all cryptographic operations.

### `convert_pfx.sh` Usage

1. Navigate to the `certificate-management` folder
2. Run `convert_pfx.sh` with the required input `.pfx` file and the desired options for extraction or display.

    ```text
    ./certificate-management/convert_pfx.sh -i <path/to/bundle.pfx> [options]
    ```

    1. You will be asked for the password to the .pfx file

        ```text
        Enter password for /path/to/MY_BUNDLE.pfx:

        ```

3. If the password is correct, you will obtain the cryptographic component or data you requested using the options.

### `convert_pfx.sh` Options

```text
Required Options:
  -i, --input <path>        Specify the input .pfx file

Optional File Types to extract
  -p, --private             Extract private key             name.insecure.pem
  -P, --public              Extract public key              name.pub
  -c, --certificate         Extract certificate             name.crt
  -C, --chain               Extract full certificate chain  name.chain.crt
  -r, --root-ca             Extract root CA certificate     name.root.crt

  -s, --standard            Effectively the same as -p -c
  -a, --all                 Effectively the same as -p -P -c -C -r

Optional modifiers:
  -o, --output <path>       Specify base name for output files (default to .pfx filename)
  -d, --details             Show details about the .pfx file
  -q, --quiet               Run in quiet mode
                              Provide password via PFX_PASSWORD environment variable
  -v, --verbose             Run in verbose mode
  -h, --help                Show this help message
```

### `convert_pfx.sh` Examples

1. Extract private key, certificate, and chain certificate:

    ```bash
    ./certificate-management/convert_pfx.sh -i /path/to/bundle.pfx -p -c -C
    ```

    The following will be created:
      - private key:
        - `./bundle.insecure.pem`
      - client certificate:
        - `./bundle.crt`
      - chain certificate:
        - `./bundle.chain.crt`

2. Extract all components and specify a custom output base name:

    ```bash
    ./certificate-management/convert_pfx.sh -i bundle.pfx -a -o /path/to/output
    ```

    The following will be created:
      - private key:
        - `/path/to/output.insecure.pem`
      - public key:
        - `/path/to/output.pub`
      - client certificate:
        - `/path/to/output.crt`
      - chain certificate:
        - `/path/to/output.chain.crt`
      - root certificate:
        - `/path/to/output.root.crt`

3. Display details of the `.pfx` file without extraction:

    ```bash
    ./certificate-management/convert_pfx.sh -i /path/to/bundle.pfx -d
    ```

    Details about the .pfx file, no additional files will be created
