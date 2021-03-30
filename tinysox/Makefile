include $(TOPDIR)/rules.mk

PKG_NAME:=tinysox
PKG_VERSION:=2021.03-git
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/DarkCaster/TinySox.git
PKG_SOURCE_VERSION=e04008938251247f61db627c2adad36232818904
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_CXXFLAGS+=-O2 -fomit-frame-pointer -flto -fuse-linker-plugin -ffat-lto-objects
TARGET_LDFLAGS+=-flto -fuse-linker-plugin -ffat-lto-objects

define Package/tinysox/config
menu "Configuration"
	depends on PACKAGE_tinysox
	config TINYSOX_REQUIRE_NETNS
		bool "Network namespaces support"
		help
			"Enforce kernel options required for network namespaces support"
		default y
endmenu
endef

define Package/tinysox
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=SOCKS5 server with minimal feature-set
  USERID:=tinysox:tinysox
  DEPENDS:= \
    +@TINYSOX_REQUIRE_NETNS:KERNEL_NET_NS \
    +@TINYSOX_REQUIRE_NETNS:KERNEL_NAMESPACES \
    +libstdcpp \
    +libudns
  URL:=https://github.com/DarkCaster/TinySox
endef

define Package/tinysox/description
SOCKS5 server with minimal feature-set (RFC1928 and RFC1929) intended for use with small memory constrained devices running Linux/OpenWRT.
endef

define Package/tinysox/conffiles
/etc/config/tinysox
endef

define Package/tinysox/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/tinysox.config $(1)/etc/config/tinysox
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tinysox.init $(1)/etc/init.d/tinysox
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tinysox $(1)/usr/sbin/tinysox
endef

$(eval $(call BuildPackage,tinysox))
