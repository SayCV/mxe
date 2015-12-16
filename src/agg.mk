# This file is part of MXE.
# See index.html for further information.

PKG             := agg
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.5
$(PKG)_CHECKSUM := ab1edc54cc32ba51a62ff120d501eecd55fceeedf869b9354e7e13812289911f
$(PKG)_SUBDIR   := agg-$($(PKG)_VERSION)
$(PKG)_FILE     := agg-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://www.antigrain.com/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc freetype sdl

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.antigrain.com/download/index.html' | \
    $(SED) -n 's,.*<A href="http://www.antigrain.com/agg-\([0-9.]*\).tar.gz".*,\1,p' | \
    head -1
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      $(foreach f,authors news readme, mv '$(1)/$f' '$(1)/$f_';mv '$(1)/$f_' '$(1)/$(call uc,$f)';)
      cd '$(1)' && autoreconf -fi -I $(PREFIX)/$(TARGET)/share/aclocal
      mkdir -p '$(1).build'
      cd '$(1).build' && ../$(1)/configure \
          $(MXE_CONFIGURE_OPTS) \
          --without-x \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
    if [ ! -e $(shell dirname $(1))/check_make_install_stamp ]; then \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= \
      && touch $(shell dirname $(1))/check_make_install_stamp; \
    fi
endef

$(PKG)_BUILD_x86_64-w64-mingw32 =
$(PKG)_BUILD_SHARED =
