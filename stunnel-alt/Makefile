#
# Copyright (C) 2006-2014 OpenWrt.org
# Copyright (C) 2021 Alexander Gromov <dark.caster@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stunnel-alt
PKG_VERSION:=5.58
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
PKG_HASH:=d4c14cc096577edca3f6a2a59c2f51869e35350b3988018ddf808c88e5973b79

PKG_FIXUP:=autoreconf
PKG_FIXUP:=patch-libtool
PKG_INSTALL:=1

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
/etc/stunnel-alt/stunnel.conf
/etc/config/stunnel
endef


CONFIGURE_ARGS+= \
	--with-random=/dev/urandom \
	--with-threads=pthread \
	--with-ssl=$(STAGING_DIR)/usr \
	--disable-libwrap \
	--disable-systemd

ifeq ($(CONFIG_IPV6),n)
CONFIGURE_ARGS+= \
	--disable-ipv6
endif

define Build/Compile
	mkdir -p $(PKG_INSTALL_DIR)/etc/stunnel
	echo '#dummy' > $(PKG_INSTALL_DIR)/etc/stunnel/stunnel.pem
	$(call Build/Compile/Default)
endef

define Package/stunnel-alt/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stunnel $(1)/usr/bin/stunnel-alt
	$(INSTALL_DIR) $(1)/usr/lib/stunnel
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/stunnel/libstunnel.so $(1)/usr/lib/stunnel/
	$(INSTALL_DIR) $(1)/etc/stunnel-alt
	$(INSTALL_CONF) ./files/stunnel.conf $(1)/etc/stunnel-alt/stunnel.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/stunnel.init $(1)/etc/init.d/stunnel-alt
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/stunnel.uci $(1)/etc/config/stunnel-alt
endef

$(eval $(call BuildPackage,stunnel-alt))
