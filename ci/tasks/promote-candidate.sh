#!/usr/bin/env bash

set -e -x

source dummy-release/ci/tasks/utils.sh

check_param s3_access_key_id
check_param s3_secret_access_key

source /etc/profile.d/chruby.sh
chruby 2.1.2

# Creates an integer version number from the semantic version format
# May be changed when we decide to fully use semantic versions for releases
integer_version=`cut -d "." -f1 release-version-semver/number`
echo $integer_version > promoted/integer_version

cp -r dummy-release promoted/repo

dev_release=$(echo $PWD/dummy-dev-artifacts/*.tgz)

pushd promoted/repo
  set +x
  echo creating config/private.yml with blobstore secrets
  cat > config/private.yml << EOF
---
blobstore:
  s3:
    access_key_id: $s3_access_key_id
    secret_access_key: $s3_secret_access_key
EOF

  cat config/private.yml
  set -x

  echo "using bosh CLI version..."
  bosh version

  echo "finalizing CPI release..."
  bosh finalize release ${dev_release} --version $integer_version

  rm config/private.yml

  git diff | cat
  git add .

  git config --global user.email zhanggbj@cn.ibm.com
  git config --global user.name zhanggbj
  git commit -m "New dummy final release v $integer_version"
popd


