#!/usr/bin/env sh

# This bootstraps Puppet on Debian
set -e

# Do the initial apt-get update
echo "Initial apt-get update..."
apt-get update >/dev/null

# Older versions of Debian don't have lsb_release by default, so
# install that if we have to.
which lsb_release || apt-get --yes install lsb-release

# Load up the release information
DISTRIB_CODENAME=$(lsb_release -c -s)

PUPPET_COLLECTION=${PUPPET_COLLECTION:-"6"}
case "${PUPPET_COLLECTION}" in
6|7)   PUPPETLABS_RELEASE_DEB="http://apt.puppetlabs.com/puppet${PUPPET_COLLECTION}-release-${DISTRIB_CODENAME}.deb" ;;
*)
  echo "Unknown/Unsupported PUPPET_COLLECTION." >&2
  exit 1
esac


#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Install wget if we have to (some older Debian versions)
echo "Installing wget..."
apt-get --yes install wget >/dev/null

# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
wget --output-document="${repo_deb_path}" "${PUPPETLABS_RELEASE_DEB}" 2>/dev/null
dpkg -i "${repo_deb_path}" >/dev/null
rm "${repo_deb_path}"

apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet..."
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet-agent >/dev/null

echo "Puppet installed!"
