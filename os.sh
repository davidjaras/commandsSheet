## Iptables (https://gist.github.com/davydany/0ad377f6de3c70056d2bd0f1549e1017)
# Print out all rules
iptables -n -L -v --line-numbers

# List rules for a specific chain(INPUT, OUTPUT)
iptables -L INPUT
iptables -S INPUT # Specifications

# Drop rule
# Explanation
# -D <CHAIN>    : The Rule to delete (INPUT -s 127.0.0.1 -p tcp -dport 111 -j ACCEPT)
# -s <SOURCE>   : Source - The Source IP of the connection (127.0.0.1)
# -p <protocol> : Protocol - THe protocol of the rule or of the packet to check 
# --dport <port>: Destination Port: The Destination port or port range specification
# -j <ACTION>   : (jump) - Defines what to do when the Packet matches this rule. We can either ACCEPT, DROP or REJECT it. (REJECT)
iptables -D INPUT -s 127.0.0.1 -p tcp -dport 111 -j ACCEPT 

# Drop a rule
iptables -I OUTPUT -p tcp -d rtf-management-service.kstg.msap.io -j DROP

# Drop rule by line number
iptables -D INPUT 10

# Flush all chains
iptables -F

# Insert rule
iptables -I INPUT 2 -s 202.54.1.2 -j DROP

# Encode base64
echo "text" | base64

# Decode base64
echo "dGV4dAo=" | base64 --decode

# List file descriptors where postgress has a connection
# It help us to know how many connections a node has
lsof -p 3590 | grep "postgres (ESTABLISHED)" | wc -l

# Create a GPG key
gpg --gen-key
gpg --full-generate-key

# Remove GPG key
gpg --delete-secret-keys
gpg --delete-key <id>

# Export GPG public key
gpg --armor --export <id>
gpg --export --armor youremail@example.com > mypubkey.asc

# Import GPG public key
gpg --import theirpubkey.asc

# List GPG keys
gpg --list-keys
gpg --list-secret-keys
gpg --list-secret-keys --keyid-format LONG

# Encrypt a file with GPG
gpg --encrypt --recipient glenn filename.txt
gpg --encrypt --recipient 'my_name' filename.txt # The recipient specify who can see it
gpg --encrypt --recipient glenn --recipient 'my_name' filename.txt # Me and another person
gpg -e -r journalists filename.txt

# Decrypt a file with GPG
gpg --decrypt filename.txt.gpg

# Generate random base64
openssl rand -base64 ${SIZE:-16}

# Generate a new private key and Certificate Signing Request
openssl req -out CSR.csr -new -newkey rsa:2048 -nodes -keyout privateKey.key

# Generate a self-signed certificate (CRT)
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out certificate.crt

# Generate a certificate signing request (CSR) for an existing private key
openssl req -out CSR.csr -key privateKey.key -new

# Generate a certificate signing request based on an existing certificate
openssl x509 -x509toreq -in certificate.crt -out CSR.csr -signkey privateKey.key

# Generate RSA keys
openssl genrsa -out private.pem 1024

# Remove a passphrase from a private key
openssl rsa -in privateKey.pem -out newPrivateKey.pem

# Check PEM file passphrase
openssl pkey -in brodcast.pem

# Check a Certificate Signing Request (CSR)
openssl req -text -noout -verify -in CSR.csr

# Check a private key
openssl rsa -in privateKey.key -check

# Check a certificate X509
openssl x509 -in certificate.crt -text -noout

# Check a certificate from P12 file
openssl pkcs12 -info -nodes -in yourfilename.p12 

# Convert P12 to PEM
## If you want to use a password to encrypt the key file, you must remove the -nodes flag
## You can add -nocerts to only output the private key or add -nokeys to only output the certificates.
openssl pkcs12 -in path.p12 -out newfile.pem -nodes
# Convert P12 to pem with only the crt
openssl pkcs12 -in <file-name>.p12 -out <new-file>.crt.pem -clcerts -nokeys

# Convert P12 to pem with only the private key
openssl pkcs12 -in <file-name>.p12 -out <new-file>.key.pem -nocerts -nodes

# Convert DER to PEM
openssl x509 -inform der -in certificate.cer -out certificate.pem

# Convert PEM to DER
openssl x509 -outform der -in certificate.pem -out certificate.der

# Convert PEM to CRT (.CRT file)
openssl x509 -outform der -in certificate.pem -out certificate.crt

# Get public key from x509 cer
openssl x509 -in certificate.pem -pubkey -noout > public_key.pem

# Get SSL certifificate
openssl s_client -showcerts -connect runtime-manager.anypoint.mulesoft.com:443 2>/dev/null | openssl x509 -noout -text


# Get the number of file descriptors opened
lsof | wc -l
