#!/bin/sh

set -eu

echo 'Installing lib32stdc++6'
if ! dpkg -s lib32stdc++6; then
    apt-get update
    apt-get install -y lib32stdc++6
fi
