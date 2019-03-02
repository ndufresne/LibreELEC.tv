# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gbmtest"
PKG_ARCH="arm aarch64"
PKG_LICENSE="BSD"
PKG_VERSION="1.0"
PKG_SITE="https://chromium.googlesource.com/chromiumos/third_party/autotest/+/master/client/site_tests/graphics_Gbm/src/"
PKG_DEPENDS_TARGET="toolchain libdrm minigbm"
PKG_SECTION="graphics"
PKG_SHORTDESC="A simple gbm test app"
PKG_AUTORECONF="no"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  export PKG_CONFIG_PATH=$SYSROOT_PREFIX/usr/include
}

make_target() {
  make ARCH=$TARGET_KERNEL_ARCH CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
       CFLAGS="$CFLAGS -O -I$SYSROOT_PREFIX/usr/include/" -C $PKG_BUILD
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
    cp -PR gbmtest $INSTALL/usr/bin
}
