# Windows AD CS - Generate Certificates

## Pre-requirements

Requires Windows Server Role:

- Active Directory Certificate Services
  - Certificate Authority
  - Certificate Authority Web Enrollment

Requires changes to Certificate Templates

1. Open `certsrv.msc`
2. Expand `Your-Domain-CA`
3. Right Click "Certificate Template" -> Select "Manage"
   1. Right click "Webserver" -> Select "Properties"
   2. Select Security Tab
      1. Select `Authenticated Users`
      2. Allow `Enroll` Permission
      3. Select "OK"

## Generate Certificate Request

1. Open Certificates
   1. run `mmc.exe`
   2. "File" -> "Add/Remove Snap-in"
      1. Add "Certificates"
      2. Select "Computer account"
      3. Ok
2. [Right Click] Personal -> All Tasks -> Advanced Operations -> Create Custom Request
3. Certificate Enrollment Window
   1. Select Certificate Enrollment Policy
      1. Custom Request -> Proceed without enrollment policy
   2. Custom request
      1. Template: (No Template)
      2. Request format: `PKCS #10`
   3. Certificate Information
      1. Expand "Details" in custom request
      2. Properties
         1. General Tab:
            1. Include a Friendly Name
            2. Optionally a description
         2. Subject Tab:
            1. Subject Name
               1. Type - Common Name:
                  1. Insert the primary DNS name for the cert
                  2. Example: `thing.example.com`
               2. Type - Alternative Names:
                  1. Type the primary DNS name for the cert
                  2. Example: `thing.example.com`
               3. Optionally add any additional "Alternative Names" as needed
                  1. DNS
                  2. IP
         3. Extensions Tab:
            1. Key usage:
               1. Digital signature
               2. Key encipherment
            2. Extended Key Usage
               1. Server Authentication
         4. Private Key Tab:
            1. Key options:
               1. Key size: `4096`
               2. Select "Make private key exportable"
            2. Optional
               1. If you need to change the hashing algorithm change it in "Select Hashing Algorithm"
      3. Select Apply
      4. Select OK
   4. Select Next
   5. Save the Request to the file system

## Generate Certificate

1. Navigate <http://localhost/certsrv/> in any browser
2. Select "Request a certificate"
3. Select "Advanced certificate request"
   1. Paste the contents of the Request file you generated in the last step
   2. Certificate Template:
      1. "Web Server"
4. Submit
5. Download certificate

## Import Certificate to the Domain

1. Open Certificates
   1. run `mmc.exe`
   2. "File" -> "Add/Remove Snap-in"
      1. Add "Certificates"
      2. Select "Computer account"
      3. Ok
2. Right click "Personal" (under Certificates)
   1. Select "All task" -> "Import"
   2. Select the certificate you created in the last step
   3. Make sure the "Personal" store is the Certificate Store is selected

## Export .pfx Certificate Bundle

1. Open Certificates
   1. 1. run `mmc.exe`
   2. "File" -> "Add/Remove Snap-in"
      1. Add "Certificates"
      2. Select "Computer account"
      3. Ok
2. Find the certificate being exported
   1. Usually found in "Personal" -> "Certificates"
3. Right click the certificate select "All tasks" -> "Export"
   1. Select "Yes, export the private key"
      1. "Personal Information Exchange - PKCS #12 (.PFX)"
         1. Include all certificate in the certificate path if possible
         2. Enable certificate privacy
   2. Enable a password
   3. Set Encryption to `AES256-SHA256`
   4. Save the file
   5. Ok

## Convert .pfx to .pem format

Export the Private Key with a password
`openssl pkcs12 -in example.pfx -nocerts -out example.key`

Export the Private Key without a password (cleaned up)
`openssl pkcs12 -in example.pfx -noenc -nocerts | openssl pkcs8 -nocrypt -out example.insecure.key`

Export the Client certificate
`openssl pkcs12 -in example.pfx -clcerts -nokeys | openssl x509 -out example.crt`

Export the Chain CA Certificate
`openssl pkcs12 -in example.pfx -cacerts -nokeys | openssl x509 -out example.chain.crt`

## Import Root CA into Trusted Certificates

### Windows

1. Open `Certificates - Local Computer`
   1. Windows search `certlm.msc`
2. Expand "Trusted Root Certification"
3. Import Certificates to Trusted Root Certificates
   1. Right click "Certificates" -> "All Tasks" -> Import...
4. Certificate Import Wizard
   1. Next
   2. Select your CERTIFICATE.cer, next
   3. Place all certificates in the following store:
      - "Trusted Root Certification Authorities"
   4. Next
   5. Finish
