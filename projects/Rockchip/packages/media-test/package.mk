# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="media-test"
PKG_VERSION="2019"
PKG_SHA256=""
PKG_ARCH="any"
PKG_LICENSE="other"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC=""
PKG_TOOLCHAIN="manual"

make_target() {
  $CC media-test.c -ludev -o media-test
}
