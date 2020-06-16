include $(TOPDIR)/rules.mk

PKG_NAME:=dnsdist-lite
PKG_VERSION:=1.5.0-rc2
PKG_RELEASE:=1

PKG_SOURCE:=dnsdist-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://downloads.powerdns.com/releases/
PKG_HASH:=a2c69a5c728a08238a7e907b55badb29e39062202d0d9d291a41919a8548bbbc

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
  TITLE:=dnsdist DNS-, DOS- and abuse-aware loadbalancer
  DEPENDS:= \
	  +boost \
	  +libatomic \
	  +libcap \
	  +libedit \
	  +lmdb \
	  +lua \
	  +re2
  URL:=https://dnsdist.org/
endef

define Package/dnsdist-lite/description
  dnsdist is a highly DNS-, DoS- and abuse-aware loadbalancer. Its goal in life
  is to route traffic to the best server, delivering top performance to legitimate
  users while shunting or blocking abusive traffic.
endef

define Package/dnsdist-lite/conffiles
/etc/dnsdist.conf
/etc/config/dnsdist
/etc/init.d/dnsdist
endef

CONFIGURE_ARGS+= \
	--with-gnu-ld \
	--disable-dnscrypt \
	--without-libsodium \
	--disable-dnstap \
	--without-protobuf \
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

TARGET_CFLAGS+=-O2 -Wno-error=format-security -Werror=strict-aliasing -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_CXXFLAGS+=-O2 -Wno-error=format-security -Werror=strict-aliasing -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_LDFLAGS+=-flto -fuse-linker-plugin -ffat-lto-objects

define Package/dnsdist-lite/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/dnsdist.conf $(1)/etc/dnsdist.conf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/dnsdist.config $(1)/etc/config/dnsdist
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnsdist.init $(1)/etc/init.d/dnsdist
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnsdist $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dnsdist-lite))
