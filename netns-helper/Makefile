include $(TOPDIR)/rules.mk

PKG_NAME:=netns-helper
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

define Package/netns-helper
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Helpers for setting-up network namespaces based on veth-pair devices with minimal env on boot
	DEPENDS:= +kmod-veth +@KERNEL_NET_NS +@KERNEL_NAMESPACES
	URL:=https://github.com/DarkCaster/OpenWrt-Custom-Feed
endef

define Build/Compile
	true
endef

define Build/Install
	true
endef

define Build/Clean
	true
endef

define Package/netns-helper/conffiles
/etc/config/netns
endef

define Package/netns-helper/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/netns-helper.config $(1)/etc/config/netns
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netns-helper.init $(1)/etc/init.d/netns-helper
endef

$(eval $(call BuildPackage,netns-helper))
