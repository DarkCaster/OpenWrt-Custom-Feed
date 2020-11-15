include $(TOPDIR)/rules.mk

PKG_NAME:=pdns-routemgr
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/DarkCaster/PDNS-RouteManager.git
PKG_SOURCE_VERSION=379c4717a3d0da4c92657a9498f01b65553fb93d
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=protobuf/host
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

###TARGET_CFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
###TARGET_CXXFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
###TARGET_LDFLAGS+=-flto -fuse-linker-plugin -ffat-lto-objects

define Package/pdns-routemgr
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=IPv4 and IPv6 routes manager
  DEPENDS:= +protobuf
  URL:=https://github.com/DarkCaster/PDNS-RouteManager
endef

define Package/pdns-routemgr/description
Install and remove ipv4/ipv6 routes based on DNS answers from PowerDNS remote-logger to provide access to company-internal resources via separate network or gateway.
EXPERIMENTAL SOFTWARE, NOT FOR PRODUCTION USE!
endef

define Package/pdns-routemgr/conffiles
/etc/config/pdns-routemgr
endef

define Package/pdns-routemgr/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/pdns-routemgr $(1)/etc/config/pdns-routemgr
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pdns-routemgr .init $(1)/etc/init.d/pdns-routemgr
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pdns-routemgr $(1)/usr/sbin/pdns-routemgr
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci.defaults $(1)/etc/uci-defaults/99-pdns-routemgr
endef

$(eval $(call BuildPackage,pdns-routemgr))
