# This file is part of MXE.
# See index.html for further information.

PKG             := apr-util
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.5.4
$(PKG)_CHECKSUM := 976a12a59bc286d634a21d7be0841cc74289ea9077aa1af46be19d1a6e844c19
$(PKG)_SUBDIR   := apr-util-$($(PKG)_VERSION)
$(PKG)_FILE     := apr-util-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://archive.apache.org/dist/apr/$($(PKG)_FILE)
$(PKG)_URL_2    := http://mirror.apache-kr.org/apr/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc apr expat libiconv

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://apr.apache.org/download.cgi' | \
    grep 'aprutil1.*best' |
    $(SED) -n 's,.*APR-util \([0-9.]*\).*,\1,p'
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      mkdir -p '$(1).build'; \
      cd '$(1).build' && ../$(1)/configure \
        $(MXE_CONFIGURE_OPTS) \
        --without-pgsql \
        --without-sqlite2 \
        --without-sqlite3 \
        --without-freetds \
        --with-apr='$(PREFIX)/$(TARGET)' \
        CFLAGS=-D_WIN32_WINNT=0x0500 \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
    if [ ! -e $(shell dirname $(1))/check_make_stamp ]; then \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' $(MXE_DISABLE_CRUFT) LDFLAGS=-no-undefined \
      && touch $(shell dirname $(1))/check_make_stamp; \
    fi
    if [ ! -e $(shell dirname $(1))/check_make_install_stamp ]; then \
      $(MAKE) -C '$(1).build' -j 1 install $(MXE_DISABLE_CRUFT) \
      && touch $(shell dirname $(1))/check_make_install_stamp; \
    fi
    
    $(if $(BUILD_STATIC), \
        $(SED) -i '1i #define APU_DECLARE_STATIC 1' \
            '$(PREFIX)/$(TARGET)/include/apr-1/apu.h')
    ln -sf '$(PREFIX)/$(TARGET)/bin/apu-1-config' '$(PREFIX)/bin/$(TARGET)-apu-1-config'
endef
