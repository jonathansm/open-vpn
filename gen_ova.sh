#!/bin/bash
#Dir where easy-rsa is placed
EASY_RSA_DIR="/etc/openvpn/easy-rsa"
KEYS_DIR="$EASY_RSA_DIR/pki"
# Dir where profiles will be placed
OVPN_PATH="/etc/openvpn/ovpn-profiles"
REMOTE=“server.address 443"
 
 
if [ -z "$1" ]
then 
        echo -n "Enter new client common name (CLIENT): "
        read -e CLIENT
else
        CLIENT=$1
fi
 
 
if [ -z "$CLIENT" ]
        then echo "You must provide a CN."
        exit
fi
 
cd $EASY_RSA_DIR
if [ -f $KEYS_DIR/issued/$CLIENT.crt ]
then 
        echo "Certificate with the CN $CLIENT already exists!"
        echo " $KEYS_DIR/issued/$CLIENT.crt"
	echo "Generating ovpn profile"
else
#source ./vars
./easyrsa build-client-full $CLIENT nopass
fi
cat > $OVPN_PATH/${CLIENT}.ovpn << END
client
proto tcp
remote $REMOTE
cipher AES-256-CBC
dev tun
resolv-retry infinite
nobind
persist-key
persist-tun
auth-nocache
remote-cert-tls server
auth SHA256
tls-client
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-128-GCM-SHA256
setenv opt block-outside-dns

verb 3

<ca>
`cat $KEYS_DIR/ca.crt`
</ca>
 
<cert>
`sed -n '/BEGIN/,$p' $KEYS_DIR/issued/${CLIENT}.crt`
</cert>
 
<key>
`cat $KEYS_DIR/private/${CLIENT}.key`
</key>

key-direction 1
<tls-auth>
`cat /etc/openvpn/tls-auth.key`
</tls-auth>
END
