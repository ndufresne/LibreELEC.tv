################################################################################
#      This file is part of LibreELEC - https://libreelec.tv
#      Copyright (C) 2018 Team LibreELEC
#
#  LibreELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  LibreELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="kernel-backports"
PKG_VERSION="4.4.2-1"
PKG_SHA256="a979e194c2ed9fdfca092a448e626d85c5af0e4de5ad993c0967afd15af01285"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kernel.org"
PKG_URL="https://www.kernel.org/pub/linux/kernel/projects/backports/stable/v4.4.2/backports-$PKG_VERSION.tar.xz"
PKG_SOURCE_DIR="backports-$PKG_VERSION"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_SECTION="driver"
PKG_LONGDESC="The backports project provides device drivers from recent versions of Linux usable on older Linux kernel releases."
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  cp $PKG_DIR/config/backports.config $PKG_BUILD/.config
  unset CFLAGS
  unset LDFLAGS
}

make_target() {
  make oldconfig \
       CC=gcc \
       KLIB=$INSTALL \
       KLIB_BUILD=$(kernel_path)
  LDFLAGS="" CFLAGS="" make \
       KLIB=$INSTALL \
       KLIB_BUILD=$(kernel_path) \
       ARCH=$TARGET_KERNEL_ARCH \
       CROSS_COMPILE=$TARGET_KERNEL_PREFIX
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/kernel
    find . -name \*.ko -exec cp --parents {} $INSTALL/$(get_full_module_dir)/kernel \;
}
