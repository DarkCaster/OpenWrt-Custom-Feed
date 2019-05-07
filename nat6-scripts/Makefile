include $(TOPDIR)/rules.mk

PKG_NAME:=nat6-scripts
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Alexander Gromov <dark.caster@outlook.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

define Package/nat6-scripts
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libip6tc +ip6tables +ip6tables-mod-nat +kmod-ipt-nat6 +kmod-nf-nat6
  TITLE:=Scripts for setting-up ipv6 nat, base on this project: https://github.com/akatrevorjay/openwrt-masq6
  SUBMENU:=Firewall
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

define Package/nat6-scripts/conffiles
/etc/firewall.nat6.chains
endef

define Package/nat6-scripts/install
	$(INSTALL_DIR) $(1)/usr/share/nat6-scripts
	$(INSTALL_DATA) ./files/firewall.include $(1)/usr/share/nat6-scripts/firewall.include
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/uci.defaults $(1)/etc/uci-defaults/99-nat6
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/firewall.nat6.chains $(1)/etc
endef

$(eval $(call BuildPackage,nat6-scripts))
