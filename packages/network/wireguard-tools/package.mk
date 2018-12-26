# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wireguard-tools"
PKG_VERSION="0.0.20181218"
PKG_SHA256="2e9f86acefa49dbfb7fa6f5e10d543f1885a2d5460cd5e102696901107675735"
PKG_LICENSE="GPLv2"
PKG_SITE="https://www.wireguard.com"
PKG_URL="https://git.zx2c4.com/WireGuard/snapshot/WireGuard-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain libmnl"
PKG_LONGDESC="userspace tools for the WireGuard VPN kernel module"
PKG_TOOLCHAIN="manual"

make_target() {
  make ARCH=$TARGET_KERNEL_ARCH \
       CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
       WITH_BASHCOMPLETION=no \
       WITH_WGQUICK=no \
       WITH_SYSTEMDUNITS=no -C src/tools wg
}

post_make_target() {
  mkdir -p $INSTALL/usr/bin
    cp $PKG_BUILD/src/tools/wg $INSTALL/usr/bin
    cp $PKG_DIR/scripts/wireguard-setup $INSTALL/usr/bin

  mkdir -p $INSTALL/usr/config
    cp $PKG_DIR/config/wireguard.conf.sample $INSTALL/usr/config

  mkdir -p $INSTALL/etc/wireguard
    ln -sf /storage/.config/wireguard.conf $INSTALL/etc/wireguard/wg0.conf
}

post_install() {
  enable_service wireguard-defaults.service
}
