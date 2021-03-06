# This file is part of MXE.
# See index.html for further information.

PKG             := lua
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.3.2
# Shared version and luarocks subdir
$(PKG)_SHORTVER := $(call SHORT_PKG_VERSION,$(PKG))
$(PKG)_CHECKSUM := c740c7bb23a936944e1cc63b7c3c5351a8976d7867c5252c8854f7b2af9da68f
$(PKG)_SUBDIR   := lua-$($(PKG)_VERSION)
$(PKG)_FILE     := lua-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://www.lua.org/ftp/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS     := gcc
$(PKG)_DEPS_$(BUILD) :=

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.lua.org/download.html' | \
    $(SED) -n 's,.*lua-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD_COMMON
    #pkg-config file
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: $(PKG)'; \
     echo 'Libs: -l$(PKG)';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(2).c' -o '$(PREFIX)/$(TARGET)/bin/test-lua.exe' \
        `$(TARGET)-pkg-config --libs lua`
endef

define $(PKG)_BUILD
    $(MAKE) -C '$(1)/src' -j '$(JOBS)' \
        INSTALL_TOP='$(PREFIX)/$(TARGET)' \
        CC='$(TARGET)-gcc' \
        AR='$(TARGET)-ar rcu' \
        RANLIB='$(TARGET)-ranlib' \
        a lua

    # lua.h is installed to noinstall/ to avoid error when executing an empty
    # 'install' command.
    $(MAKE) -C '$(1)' -j 1 \
        INSTALL_TOP='$(PREFIX)/$(TARGET)' \
        INSTALL_BIN='$(1)/noinstall' \
        INSTALL_MAN='$(1)/noinstall' \
        TO_BIN='lua.h' \
        INSTALL='$(INSTALL)' \
        install
    cp '$(1)/src/lua' '$(PREFIX)/$(TARGET)/bin/lua.exe'
    $($(PKG)_BUILD_COMMON)
endef

define $(PKG)_BUILD_SHARED
    $(MAKE) -C '$(1)/src' -j '$(JOBS)' \
        INSTALL_TOP='$(PREFIX)/$(TARGET)' \
        CC='$(TARGET)-gcc' \
        AR='$(TARGET)-gcc -Wl,--out-implib,liblua.dll.a -shared -o' \
        RANLIB='echo skipped ranlib' \
        SYSCFLAGS='-DLUA_BUILD_AS_DLL' \
        LUA_A=liblua$($(PKG)_SHORTVER).dll \
        a lua
    $(MAKE) -C '$(1)' -j 1 \
        INSTALL_TOP='$(PREFIX)/$(TARGET)' \
        INSTALL_MAN='$(1)/noinstall' \
        TO_BIN='liblua$($(PKG)_SHORTVER).dll' \
        INSTALL='$(INSTALL)' \
        TO_LIB='liblua.dll.a' \
        install
    cp '$(1)/src/lua' '$(PREFIX)/$(TARGET)/bin/lua.exe'
    $($(PKG)_BUILD_COMMON)
endef

define $(PKG)_BUILD_$(BUILD)
    $(MAKE) -C '$(1)/src' -j '$(JOBS)' \
        PLAT=$(shell ([ `uname -s` == Darwin ] && echo "macosx") || echo `uname -s` | tr '[:upper:]' '[:lower:]')
    $(INSTALL) '$(1)/src/lua' '$(PREFIX)/bin/$(BUILD)-lua'
    ln -sf '$(PREFIX)/bin/$(BUILD)-lua' '$(PREFIX)/$(BUILD)/bin/lua'
    $(INSTALL) '$(1)/src/luac' '$(PREFIX)/bin/$(BUILD)-luac'
    ln -sf '$(PREFIX)/bin/$(BUILD)-luac' '$(PREFIX)/$(BUILD)/bin/luac'
endef
