#
# Copyright (C) 2006-2014 OpenWrt.org
# Copyright (C) 2021 Alexander Gromov <dark.caster@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tinyproxy-alt
PKG_VERSION:=1.11.0-git
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tinyproxy/tinyproxy.git
PKG_SOURCE_VERSION=adad565c03f3ffde6520646bc5d119ce1eadbadb
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

#PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_CXXFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_LDFLAGS+=-flto -fuse-linker-plugin -ffat-lto-objects

define Package/tinyproxy-alt
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Tinyproxy is a lightweight HTTP and HTTPS proxy
  DEPENDS:= +@KERNEL_NET_NS +@KERNEL_NAMESPACES
  URL:=https://tinyproxy.github.io/
endef

define Package/tinyproxy-alt/description
Tinyproxy with support running it within network namespace
endef

define Package/tinyproxy-alt/conffiles
/etc/config/tinyproxy-alt
endef

CONFIGURE_VARS += ac_cv_path_A2X=no

define Package/tinyproxy-alt/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/tinyproxy $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/tinyproxy
	$(CP) $(PKG_INSTALL_DIR)/usr/share/tinyproxy/*.html $(1)/usr/share/tinyproxy/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/tinyproxy.config $(1)/etc/config/tinyproxy
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tinyproxy.init $(1)/etc/init.d/tinyproxy
endef

$(eval $(call BuildPackage,tinyproxy))
