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

# Get SSL certifificate
openssl s_client -showcerts -connect runtime-manager.anypoint.mulesoft.com:443 2>/dev/null | openssl x509 -noout -text

# Get certificate content of a file
openssl x509 -in ${cert_file} -text -noout


# Get the number of file descriptors opened
lsof | wc -l
