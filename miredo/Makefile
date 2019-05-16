#
# Copyright (C) 2006-2012 OpenWrt.org
# Copyright (C) 2017 Petr Pudlak
# Copyright (C) 2019 Alexander Gromov
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# Developer notes:
#   - Make sure you have gawk, othwerise you get weird syntax errors about "("
#     and ")" when compiling.
#   - Install ccache, otherwise you'll get configure error:
#     "C compiler cannot create executables"

include $(TOPDIR)/rules.mk

PKG_NAME:=miredo
PKG_VERSION:=1.2.99
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=http://git.remlab.net/git/miredo.git
PKG_SOURCE_VERSION=509603ab416cd8f57e9227d09a8a80289df1a9f1
PKG_BUILD_DEPENDS:=gettext-full/host

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>

PKG_FIXUP:=autoreconf
PKG_FIXUP:=patch-libtool
PKG_FIXUP:=gettext-version
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

CONFIGURE_ARGS+=--without-pic --without-libiconv-prefix --without-libintl-prefix --disable-shared --disable-static --disable-nls --disable-assert --enable-miredo-user=root --enable-teredo-client
CONFIGURE_VARS+=LD="$(TARGET_CC_NOCACHE)" CC="$(TARGET_CC_NOCACHE)" CPP="$(TARGET_CPP_NOCACHE)"

TARGET_CFLAGS+=-O3 -Wno-error=format-security -Werror=strict-aliasing -fomit-frame-pointer -flto -fwhole-program
TARGET_CXXFLAGS+=-O3 -Wno-error=format-security -Werror=strict-aliasing -fomit-frame-pointer -flto -fwhole-program
TARGET_LDFLAGS+=-flto -fwhole-program

define Package/miredo/Default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=miredo: Teredo (IPv6 tunneling over UDP through NAT)
	URL:=https://www.remlab.net/miredo/
endef

define Package/miredo-common
$(call Package/miredo/Default)
  TITLE:=Teredo (IPv6 tunneling over UDP through NAT) shared libraries
  DEPENDS:=+libpthread +librt +ip +kmod-tun +libcap
endef

define Package/miredo-server
$(call Package/miredo/Default)
  TITLE:=Teredo (IPv6 tunneling over UDP through NAT) server daemon (UNTESTED!)
  DEPENDS+= +miredo-common
endef

define Package/miredo-server/conffiles
/etc/miredo/miredo-server.conf
endef

define Package/miredo-client
$(call Package/miredo/Default)
  TITLE:=Teredo (IPv6 tunneling over UDP through NAT) client and relay daemon
  DEPENDS+= +miredo-common
endef

define Package/miredo-client/conffiles
/etc/miredo/miredo.conf
endef

define Package/miredo-common/install
	$(INSTALL_DIR) $(1)/usr/lib/miredo
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/miredo/miredo-privproc $(1)/usr/lib/miredo
endef

define Package/miredo-server/install
	$(INSTALL_DIR) $(1)/etc/miredo
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/miredo/examples/miredo-server.conf $(1)/etc/miredo/miredo-server.conf
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etc/miredo/client-hook $(1)/etc/miredo/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/miredo-server.init $(1)/etc/init.d/miredo-server
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/miredo-server $(1)/usr/sbin/
endef

define Package/miredo-client/install
	$(INSTALL_DIR) $(1)/etc/miredo
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/miredo/examples/miredo.conf $(1)/etc/miredo/miredo.conf
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/etc/miredo/client-hook $(1)/etc/miredo/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/miredo.init $(1)/etc/init.d/miredo-client
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/miredo $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/miredo-checkconf $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci.defaults.client $(1)/etc/uci-defaults/99-miredo-client
endef

define Build/Prepare
	$(Build/Prepare/Default)
	( cd $(PKG_BUILD_DIR) && cp $(STAGING_DIR)/../hostpkg/share/gettext/gettext.h ./include/gettext.h )
endef

$(eval $(call BuildPackage,miredo-common))
$(eval $(call BuildPackage,miredo-server))
$(eval $(call BuildPackage,miredo-client))
