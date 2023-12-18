#!/usr/bin/env tinyrange
#tinyrange size xl
#tinyrange storage-size lg
#tinyrange arch arm64
#tinyrange file https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.7.tar.xz
#tinyrange file config_arm64
#tinyrange pull-file /root/vmlinux_arm64

set -ex
# set -x
source /etc/profile

apk add make libc-dev gcc g++ flex bison cmd:find gmp-dev mpc1-dev perl openssl-dev ccache

export CCACHE_DIR=/root/ccache/

mkdir $CCACHE_DIR

cat <<EOF > $CCACHE_DIR/ccache.conf
cache_dir = /root/ccache/cache/
remote_storage = http://host.internal/cache/
remote_only = true
EOF

(cd /root;tar -xf linux-6.6.7.tar.xz)

(cd /root/linux-6.6.7;mv /root/config_arm64 .config)

(cd /root/linux-6.6.7;make oldconfig)

(cd /root/linux-6.6.7;cat .config | /init -cachePut linux_kernel/config_arm64)

export KBUILD_BUILD_TIMESTAMP=''

(cd /root/linux-6.6.7;make CC="ccache gcc" -j4)

mv /root/linux-6.6.7/arch/arm64/boot/Image /root/vmlinux_arm64
