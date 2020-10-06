# based on official stubby package by Jonathan Underwood, BSD-3-Clause license

include $(TOPDIR)/rules.mk

PKG_NAME:=getdns-alt
PKG_VERSION:=1-git
PKG_RELEASE:=1
PKG_BUILD_DEPENDS:=openssl

PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/getdnsapi/getdns.git
PKG_SOURCE_VERSION=ebeff971929867fdbc2f4d17dafd43893788a657

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

define Package/getdns-alt/Default
	TITLE:=getdns-alt
	URL:=https://getdnsapi.net/
endef

define Package/getdns-alt
	$(call Package/getdns-alt/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE+= (library)
	MENU:=1
endef

define Package/getdns-alt/description
  This package contains the getdns library (libgetdns) for use with stubby-alt package. Not intended for installation.
endef

CMAKE_OPTIONS += -DBUILD_LIBEV=OFF
CMAKE_OPTIONS += -DBUILD_LIBEVENT2=OFF
CMAKE_OPTIONS += -DBUILD_LIBUV=OFF
CMAKE_OPTIONS += -DENABLE_STUB_ONLY=ON
CMAKE_OPTIONS += -DUSE_LIBIDN2=OFF
CMAKE_OPTIONS += -DBSD_LIBRARY=OFF
CMAKE_OPTIONS += -DENABLE_SHARED=OFF
CMAKE_OPTIONS += -DENABLE_STATIC=ON
CMAKE_OPTIONS += -DBUILD_TESTING=OFF

$(eval $(call BuildPackage,getdns-alt))
