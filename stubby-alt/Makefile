# based on official stubby package by Jonathan Underwood, BSD-3-Clause license

include $(TOPDIR)/rules.mk

PKG_NAME:=stubby-alt
PKG_VERSION:=2020.10.06-git
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/getdnsapi/stubby.git
PKG_SOURCE_VERSION=5c37fa25b3985c703edb471ec03f3003b9f48c12
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_BUILD_DEPENDS:=getdns-alt
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_CXXFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_LDFLAGS+=-flto -fuse-linker-plugin -ffat-lto-objects

define Package/stubby-alt/Default
  TITLE:=stubby-alt
  URL:=https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby
endef

define Package/stubby-alt
  $(call Package/stubby-alt/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Stubby dns-resolver
  USERID:=stubby=410:stubby=410
  DEPENDS:= +libyaml +libopenssl +ca-certs
endef

define Package/stubby-alt/description
  This package contains the Stubby daemon. This build implements alternative init approach using native configuration and multiple daemon-instances support.
endef

define Package/stubby-alt/conffiles
/etc/config/stubby-alt
endef

define Package/stubby-alt/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stubby $(1)/usr/sbin/stubby-alt
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/stubby.init $(1)/etc/init.d/stubby-alt
	$(INSTALL_DIR) $(1)/usr/share/stubby-alt
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/stubby/stubby.yml $(1)/usr/share/stubby-alt/stubby.yml
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/stubby.config $(1)/etc/config/stubby-alt
endef

CMAKE_OPTIONS += -DENABLE_GETDNS_STATIC_LINK=ON

$(eval $(call BuildPackage,stubby-alt))
