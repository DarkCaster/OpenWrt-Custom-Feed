#
# Copyright (C) 2006-2014 OpenWrt.org
# Copyright (C) 2021 Alexander Gromov <dark.caster@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stunnel-alt
PKG_VERSION:=5.59
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE_FILES:=COPYING.md COPYRIGHT.md

PKG_SOURCE_URL:= \
	http://ftp.nluug.nl/pub/networking/stunnel/ \
	http://www.usenix.org.uk/mirrors/stunnel/ \
	https://www.stunnel.org/downloads/ \
	https://www.usenix.org.uk/mirrors/stunnel/archive/$(word 1, $(subst .,$(space),$(PKG_VERSION))).x/

PKG_SOURCE:=stunnel-$(PKG_VERSION).tar.gz
PKG_HASH:=137776df6be8f1701f1cd590b7779932e123479fb91e5192171c16798815ce9f

PKG_FIXUP:=autoreconf
PKG_FIXUP:=patch-libtool
PKG_INSTALL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/stunnel-alt-$(PKG_VERSION)/stunnel-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/stunnel-alt
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libopenssl +zlib +libpthread
  TITLE:=SSL TCP Wrapper
  URL:=http://www.stunnel.org/
endef

define Package/stunnel-alt/description
	Alternative build of stunnel utility
endef

define Package/stunnel-alt/conffiles
/etc/config/stunnel
endef

CONFIGURE_ARGS+= \
	--with-random=/dev/urandom \
	--with-threads=pthread \
	--with-ssl=$(STAGING_DIR)/usr \
	--disable-shared \
	--disable-libwrap \
	--disable-systemd

ifeq ($(CONFIG_IPV6),n)
CONFIGURE_ARGS+= \
	--disable-ipv6
endif

define Package/stunnel-alt/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stunnel $(1)/usr/bin/stunnel-alt
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/stunnel.init $(1)/etc/init.d/stunnel-alt
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/stunnel.uci $(1)/etc/config/stunnel-alt
endef

$(eval $(call BuildPackage,stunnel-alt))
