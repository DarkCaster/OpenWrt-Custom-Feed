include $(TOPDIR)/rules.mk

PKG_NAME:=online-watchdog
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

define Package/online-watchdog
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Simple always-online watchdog, will trigger restart of selected interfaces when ping to all configured addresses was failed 
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

define Package/online-watchdog/conffiles
/etc/config/online-watchdog
endef

define Package/online-watchdog/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/online-watchdog.config $(1)/etc/config/online-watchdog
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/online-watchdog.init $(1)/etc/init.d/online-watchdog
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/online-watchdog.sh $(1)/usr/sbin/online-watchdog.sh
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/online-watchdog.uci.defaults $(1)/etc/uci-defaults/99-online-watchdog
endef

$(eval $(call BuildPackage,online-watchdog))
