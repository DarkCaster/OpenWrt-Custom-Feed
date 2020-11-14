include $(TOPDIR)/rules.mk

PKG_NAME:=pdns-routemgr
PKG_VERSION:=0.1
PKG_RELEASE:=1
PKG_BUILD_DEPENDS:=protobuf/host

PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/DarkCaster/PDNS-RouteManager.git
PKG_SOURCE_VERSION=b6eaec1c0736d2202e71a130ebc510d5b52fbf0f

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_CXXFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_LDFLAGS+=-flto -fuse-linker-plugin -ffat-lto-objects

include $(INCLUDE_DIR)/package.mk

define Package/pdns-routemgr
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=IPv6 and IPv6 routes manager. EXPERIMENTAL, NOT FOR PRODUCTION USE!
  DEPENDS:= +protobuf
  URL:=https://github.com/DarkCaster/PDNS-RouteManager
endef

define Package/pdns-routemgr/description
  Install and remove ipv4/ipv6 routes based on DNS answers received from PowerDNS remote-logger. Intended to provide access to organization-internal resources via separate network interface or gateway. EXPERIMENTAL SOFTWARE, NOT FOR PRODUCTION USE!
endef

define Package/pdns-routemgr/conffiles
/etc/config/pdns-routemgr
endef

define Package/dnsdist-alt/install
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