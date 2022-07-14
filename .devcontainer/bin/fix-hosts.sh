#!/bin/bash

HOMEURL=$(wp option get HOME 2>/dev/null |sed 's|https\?://||g')
if [[  $HOMEURL != *"githubpreview.dev" ]]; then
    echo "No 'githubpreviw.dev' in your site url $HOMEURL. Doing nothing."
    exit 1
fi
EXPECTED_LINE="127.0.0.1 localhost $HOMEURL"
if grep "$EXPECTED_LINE" /etc/hosts >/dev/null; then
    echo "Hosts already configured. Doing nothing."
    exit 0
fi
echo "Setting $HOMEURL to point to 127.0.0.1 in /etc/hosts" 
rm -f /tmp/hosts.new
sed '/githubpreview.dev/ d' /etc/hosts >> /tmp/hosts.new
echo "$EXPECTED_LINE" >> /tmp/hosts.new
sudo cp /tmp/hosts.new /etc/hosts
sudo rm -f /tmp/hosts.new
echo "Done."
