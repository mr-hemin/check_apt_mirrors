#!/bin/bash

set -e

# Dynamically detect Ubuntu codename
UBUNTU_CODENAME=$(lsb_release -cs 2>/dev/null || echo "jammy")

# List of mirrors (prioritize official Ubuntu mirrors, then regional ones)
MIRRORS=(
  "https://mirrors.pardisco.co/ubuntu/"
  "http://mirror.aminidc.com/ubuntu/"
  "http://mirror.faraso.org/ubuntu/"
  "https://ir.ubuntu.sindad.cloud/ubuntu/"
  "https://ubuntu-mirror.kimiahost.com/"
  "https://archive.ubuntu.petiak.ir/ubuntu/"
  "https://ubuntu.hostiran.ir/ubuntuarchive/"
  "https://ubuntu.bardia.tech/"
  "https://mirror.iranserver.com/ubuntu/"
  "https://ir.archive.ubuntu.com/ubuntu/"
  "https://mirror.0-1.cloud/ubuntu/"
  "http://linuxmirrors.ir/pub/ubuntu/"
  "http://repo.iut.ac.ir/repo/Ubuntu/"
  "https://ubuntu.shatel.ir/ubuntu/"
  "http://ubuntu.byteiran.com/ubuntu/"
  "https://mirror.rasanegar.com/ubuntu/"
  "http://mirrors.sharif.ir/ubuntu/"
  "http://mirror.ut.ac.ir/ubuntu/"
  "http://repo.iut.ac.ir/repo/ubuntu/"
  "http://mirror.asiatech.ir/ubuntu/"
  "http://mirror.iranserver.com/ubuntu/"
  "http://archive.ubuntu.com/ubuntu/"
)

echo "🔍 Testing Ubuntu mirrors for $UBUNTU_CODENAME..."

WORKING_MIRROR=""

# Function to test mirror by checking a specific file
test_mirror() {
    local mirror=$1
    # Test for the Release file in the dists directory
    if curl -s --head --max-time 10 "$mirror/dists/$UBUNTU_CODENAME/Release" | grep -q "200 OK"; then
        return 0
    else
        return 1
    fi
}



for MIRROR in "${MIRRORS[@]}"; do
    echo -n "⏳ Testing $MIRROR ... "
    if test_mirror "$MIRROR"; then
        echo "✅ Available"
        WORKING_MIRROR=$MIRROR
        break
    else
        echo "❌ Not available"
    fi
done

if [ -z "$WORKING_MIRROR" ]; then
    echo "🚫 No repository available. Check your internet connection or firewall."
    exit 1
fi

echo "🛠 Configuring /etc/apt/sources.list with mirror: $WORKING_MIRROR"

# Backup existing sources.list
if [ -f /etc/apt/sources.list ]; then
    echo "📁 Backing up existing /etc/apt/sources.list to /etc/apt/sources.list.bak"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi

# Write new sources.list
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb ${WORKING_MIRROR} ${UBUNTU_CODENAME} main restricted universe multiverse
deb ${WORKING_MIRROR} ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb ${WORKING_MIRROR} ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb ${WORKING_MIRROR} ${UBUNTU_CODENAME}-security main restricted universe multiverse
EOF

echo ""
echo "✅ sources.list successfully configured."
echo "Now you can run the update command:"
echo ""
echo "    sudo apt update"
echo ""
