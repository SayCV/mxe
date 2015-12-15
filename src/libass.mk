# This file is part of MXE.
# See index.html for further information.

PKG             := libass
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.13.0
$(PKG)_CHECKSUM := e0071a3b2e95411c8d474014678368e3f0b852f7d663e0564b344e7335eb0671
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $($(PKG)_SUBDIR).tar.xz
$(PKG)_URL      := https://github.com/libass/libass/releases/download/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc fontconfig freetype fribidi harfbuzz

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://code.google.com/p/libass/downloads/list?sort=-uploaded' | \
    $(SED) -n 's,.*libass-\([0-9][^<]*\)\.tar.*,\1,p' | \
    head -1
endef

# fontconfig is only required for legacy XP support
define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      mkdir -p $(1).build; \
      cd '$(1).build' && ../$(1)/configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-enca \
        --enable-fontconfig \
        --enable-harfbuzz \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
    if [ ! -e $(2)/check_make_stamp ]; then \
      $(MAKE) -C '$(1)' -j '$(JOBS)' \
      && touch $(2)/check_make_stamp; \
    fi
    if [ ! -e $(2)/check_make_install_stamp ]; then \
      $(MAKE) -C '$(1)' -j 1 install \
      && touch $(2)/check_make_install_stamp; \
    fi

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(2).c' -o '$(PREFIX)/$(TARGET)/bin/test-libass.exe' \
        `'$(TARGET)-pkg-config' libass --cflags --libs`
endef
