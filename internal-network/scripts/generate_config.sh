#!/bin/bash

VARIABLES_FILES=$1
KEYS_OUT=$2

set -e
set -x
VARIABLES=$(cat $VARIABLES_FILES)
SERVER_PRIVATE_KEY=$(wg genkey)
SERVER_PUBLIC_KEY=$(echo -n "$SERVER_PRIVATE_KEY" | wg pubkey)
PEER_LENGTH=$(echo -n "$VARIABLES" | yq ".peers | length")
# KEYS_JSON="{\"server\": {\"privkey\": \"$SERVER_PRIVATE_KEY\", \"pubkey\": \"$SERVER_PUBLIC_KEY\"}, \"peers\": []}"

VARIABLES=$(echo -n "$VARIABLES" | yq ".server.privkey=\"$SERVER_PRIVATE_KEY\" | .server.pubkey=\"$SERVER_PUBLIC_KEY\"")


for ((i = 0 ; i < $PEER_LENGTH; i++)); do
	PRIVATE_KEY=$(wg genkey)
	PUBLIC_KEY=$(echo -n "$PRIVATE_KEY" | wg pubkey)

	VARIABLES=$(echo -n "$VARIABLES" | yq ".peers[$i].privkey=\"$PRIVATE_KEY\" | .peers[$i].pubkey=\"$PUBLIC_KEY\"")
	# BASE64=$(echo -n "" | base64)
	# KEYS_JSON=$(echo -n "$KEYS_JSON" | jq ".peers |= .+ [ { \"privkey\": \"$PRIVATE_KEY\", \"pubkey\": \"$PUBLIC_KEY\" } ] ")
done

echo -n "$VARIABLES" | yq --yaml-output > $KEYS_OUT

