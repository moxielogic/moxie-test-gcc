#!/bin/sh

set -x

export HOME=/home/moxie

cd ${HOME}
export PATH=/opt/moxielogic/bin:$PATH
export DEJAGNU=${HOME}/site.exp

ls -l /etc/pki/tls/certs/ca-bundle.crt 
ls -ld /etc/pki/tls/certs/ca-bundle.crt
find /etc/pki

SECRETS=`curl --verbose -H "X-Vault-Token: $VAULT_MOXIEDEV_TOKEN" -X GET https://vault-labdroid.apps.ocp.labdroid.net/v1/secret/moxiedev`
echo $SECRETS | (umask 077 && jq -r .data.id_moxiedev_rsa > /tmp/id_rsa)
git config --global user.email "bot@moxielogic.com"
git config --global user.name "Moxie Bot"

cat > ~/.msmtprc <<EOF
defaults
logfile ~/.msmtp.log

account moxielogic
tls on
tls_starttls on
tls_trust_file /etc/pki/tls/certs/ca-bundle.crt
host smtp.gmail.com
port 587
auth on
user green@moxielogic.com
password $MOXIELOGIC_MAIL_PASSWORD
from green@moxielogic.com

account default : moxielogic
EOF

git clone --progress --depth 1 https://gcc.gnu.org/git/gcc.git

# You need to run this script, as per
#   https://gcc.gnu.org/bugzilla/show_bug.cgi?id=28123
(cd gcc; ./contrib/gcc_update --touch)

patch -p0 < ${HOME}/test_results.patch

mkdir build
cd build
(../gcc/configure --prefix=/opt/moxielogic \
		  --target=moxie-elf \
		  --enable-languages=c \
		  --disable-libquadmath \
		  --disable-libssp \
		  --with-newlib \
		  --with-headers=/opt/moxielogic/moxie-elf/include;
make all;
make check RUNTESTFLAGS="CFLAGS_FOR_TARGET='-isystem /opt/moxielogic/moxie-elf/include' --target_board moxie-sim ${expfile}") 2>&1 | tee report.txt

wget -qO - https://rl.gl/cli/rlgl-linux-amd64.tgz | \
    tar --strip-components=2 -xvzf - ./rlgl/rlgl
./rlgl login --key=$RLGL_KEY https://rl.gl
export RLGL=$(./rlgl e --id=$(./rlgl start) --policy https://github.com/moxielogic/rlgl-toolchain-policy.git $(find . -name gcc.sum) || true)

(../gcc/contrib/test_summary | sh)

# cat > header.txt<<EOF
# From: Anthony Green <green@moxielogic.com>
# To: green@moxielogic.com
# Subject: moxie-elf-gcc build and test
# EOF
# (cat header.txt; cat report.txt) | msmtp -A moxielogic green@moxielogic.com

(find ./ -name gcc.log
 find ./ -name gcc.sum
 cd gcc/testsuite/gcc;
 ls -l
 git clone git@github.com:moxielogic/moxie-elf-gcc-testresults.git;
 ls -l
 cp gcc.log.sent moxie-elf-gcc-testresults/gcc.log;
 cp gcc.sum.sent moxie-elf-gcc-testresults/gcc.sum;
 cd moxie-elf-gcc-testresults;
 git add *;
 git commit -m "Test results from $(date +%F-%T)";
 git push origin master) > report.txt 2>&1

# -----------------------------------------------------------------------------

cat > header.txt<<EOF
From: Anthony Green <green@moxielogic.com>
To: green@moxielogic.com
Subject: moxie-elf-gcc testsuite git commit output
EOF
(cat header.txt; cat report.txt) | msmtp -A moxielogic green@moxielogic.com





