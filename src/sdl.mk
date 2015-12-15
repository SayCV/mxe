# This file is part of MXE.
# See index.html for further information.

PKG             := sdl
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.2.15
$(PKG)_CHECKSUM := d6d316a793e5e348155f0dd93b979798933fb98aa1edebcc108829d6474aad00
$(PKG)_SUBDIR   := SDL-$($(PKG)_VERSION)
$(PKG)_FILE     := SDL-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://www.libsdl.org/release/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc libiconv

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://hg.libsdl.org/SDL/tags' | \
    $(SED) -n 's,.*release-\([0-9][^<]*\).*,\1,p' | \
    grep '^1\.' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      cd '$(1)' && ./configure \
          $(MXE_CONFIGURE_OPTS) \
          --enable-threads \
          --enable-directx \
          --disable-stdio-redirect \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(SED) -i 's,-mwindows,-lwinmm -mwindows,' '$(1)/configure'
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
    
    if [ ! -e $(2)/check_make_stamp ]; then \
      $(MAKE) -C '$(1)' -j '$(JOBS)' \
      && touch $(2)/check_make_stamp; \
    fi
    if [ ! -e $(2)/check_make_install_stamp ]; then \
      $(MAKE) -C '$(1)' -j 1 install-bin install-hdrs install-lib install-data; \
      ln -sf '$(PREFIX)/$(TARGET)/bin/sdl-config' '$(PREFIX)/bin/$(TARGET)-sdl-config'; \
      \
      '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(2).c' -o '$(PREFIX)/$(TARGET)/bin/test-sdl.exe' \
        `'$(TARGET)-pkg-config' sdl --cflags --libs`; \
      && touch $(2)/check_make_install_stamp; \
    fi
    
    # test cmake
    if [ x$MXE_TEST_CAMKE == xyes ]; then \
      mkdir '$(1).test-cmake'; \
      cd '$(1).test-cmake' && '$(TARGET)-cmake' \
          -DPKG=$(PKG) \
          -DPKG_VERSION=$($(PKG)_VERSION) \
          '$(PWD)/src/cmake/test'; \
      $(MAKE) -C '$(1).test-cmake' -j 1 install; \
    fi
endef
