#!/usr/bin/env bash

set -e

semver=`cat version-semver/number`

pushd dummy-release

  source .envrc

  echo "installing bosh CLI"
  gem install bosh_cli --no-ri --no-rdoc

  echo "using bosh CLI version..."

  bosh version

  dummy_release_name="dummy-release"

  echo "building CPI release..."
  bosh create release --name $dummy_release_name --version $semver --with-tarball
popd

mv dummy-release/dev_releases/$dummy_release_name/$dummy_release_name-$semver.tgz candidate/











