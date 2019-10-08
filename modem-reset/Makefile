include $(TOPDIR)/rules.mk

PKG_NAME:=modem-reset
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

define Package/modem-reset
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Boot script for performing re-init of 3G-modems supporting NCM protocol
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

define Package/modem-reset/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/modem-reset.init $(1)/etc/init.d/modem-reset
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/modem-reset.uci.defaults $(1)/etc/uci-defaults/99-modem-reset
endef

$(eval $(call BuildPackage,modem-reset))
