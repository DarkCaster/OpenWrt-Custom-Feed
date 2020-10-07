include $(TOPDIR)/rules.mk

PKG_NAME:=dnsdist-lite
PKG_VERSION:=1.5.1
PKG_RELEASE:=1

PKG_SOURCE:=dnsdist-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://downloads.powerdns.com/releases/
PKG_HASH:=cae759729a87703f4d09b0ed4227cb224aaaa252fa92f2432fd7116f560afbf1

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_ASLR_PIE:=0
PKG_BUILD_DEPENDS:=libcap lmdb libre2 tinycdb lua libedit
PKG_BUILD_DIR:=$(BUILD_DIR)/dnsdist-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/dnsdist-lite
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=trimmed down version of dnsdist
  DEPENDS:= \
	  +boost \
	  +libatomic \
	  +libcap \
	  +libedit \
	  +libfstrm \
	  +lmdb \
	  +lua \
	  +re2
  URL:=https://dnsdist.org/
endef

define Package/dnsdist-lite/description
  trimmed down version of dnsdist: all protobuf- and encryption-related options were disabled, added sample configuration script
endef

define Package/dnsdist-lite/conffiles
/etc/dnsdist.cfg.lua
/etc/dnsdist.defs.lua
/etc/dnsdist.post.lua
/etc/init.d/dnsdist
endef

CONFIGURE_ARGS+= \
	--disable-dnscrypt \
	--without-libsodium \
	--enable-dnstap \
	--with-protobuf \
	--disable-dns-over-tls \
	--disable-dns-over-https \
	--disable-systemd \
	--disable-unit-tests \
	--with-pic \
	--with-re2 \
	--with-ebpf \
	--without-net-snmp \
	--with-libcap \
	--with-lua=lua \
	--without-libssl \
	--without-gnutls \
	--with-libcrypto=/dev/null \
	--with-lmdb

CONFIGURE_VARS+= \
	LIBCAP_LIBS=-lcap \
	LIBCAP_CFLAGS=-I$(STAGING_DIR)/usr/include

TARGET_CFLAGS+=-Os
TARGET_CXXFLAGS+=-Os

define Package/dnsdist-lite/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/dnsdist.cfg.lua $(1)/etc/dnsdist.cfg.lua
	$(INSTALL_CONF) ./files/dnsdist.defs.lua $(1)/etc/dnsdist.defs.lua
	$(INSTALL_CONF) ./files/dnsdist.post.lua $(1)/etc/dnsdist.post.lua
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnsdist.init $(1)/etc/init.d/dnsdist
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnsdist $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci.defaults $(1)/etc/uci-defaults/99-dnsdist
endef

$(eval $(call BuildPackage,dnsdist-lite))
