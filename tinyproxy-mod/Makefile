#
# Copyright (C) 2006-2014 OpenWrt.org
# Copyright (C) 2021 Alexander Gromov <dark.caster@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tinyproxy-mod
PKG_VERSION:=2021.02-git
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/DarkCaster/Tinyproxy-Mod.git
PKG_SOURCE_VERSION=f8db8bf7d855612c5c8cc33643f1c09a77a3ec55
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_CXXFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_LDFLAGS+=-flto -fuse-linker-plugin -ffat-lto-objects

define Package/tinyproxy-mod
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Alternative tinyproxy build
  DEPENDS:=+libudns +@KERNEL_NET_NS +@KERNEL_NAMESPACES
  URL:=https://tinyproxy.github.io/
endef

define Package/tinyproxy-mod/description
Tinyproxy with configurable DNS and network namespaces support
endef

define Package/tinyproxy-mod/conffiles
/etc/config/tinyproxy-mod
endef

CONFIGURE_VARS += ac_cv_path_A2X=no

define Package/tinyproxy-mod/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/tinyproxy $(1)/usr/bin/tinyproxy-mod
	$(INSTALL_DIR) $(1)/usr/share/tinyproxy-mod
	$(CP) $(PKG_INSTALL_DIR)/usr/share/tinyproxy/*.html $(1)/usr/share/tinyproxy-mod/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/tinyproxy.config $(1)/etc/config/tinyproxy-mod
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tinyproxy.init $(1)/etc/init.d/tinyproxy-mod
endef

$(eval $(call BuildPackage,tinyproxy-mod))
