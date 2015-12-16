# This file is part of MXE.
# See index.html for further information.

PKG             := bfd
$(PKG)_IGNORE    = $(binutils_IGNORE)
$(PKG)_VERSION   = $(binutils_VERSION)
$(PKG)_CHECKSUM  = $(binutils_CHECKSUM)
$(PKG)_SUBDIR    = $(binutils_SUBDIR)
$(PKG)_FILE      = $(binutils_FILE)
$(PKG)_URL       = $(binutils_URL)
$(PKG)_URL_2     = $(binutils_URL_2)
$(PKG)_DEPS     := gcc

define $(PKG)_UPDATE
    echo $(binutils_VERSION)
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      mkdir -p '$(1).build'; \
      cd '$(1).build' && ../$(1)/configure \
        --host='$(TARGET)' \
        --target='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --enable-install-libbfd \
        --disable-shared \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
    if [ ! -e $(shell dirname $(1))/check_make_stamp ]; then \
      $(MAKE) -C '$(1).build/bfd' -j '$(JOBS)' \
      && touch $(shell dirname $(1))/check_make_stamp; \
    fi
    if [ ! -e $(shell dirname $(1))/check_make_install_stamp ]; then \
      $(MAKE) -C '$(1).build/bfd' -j 1 install \
      && touch $(shell dirname $(1))/check_make_install_stamp; \
    fi
endef

$(PKG)_BUILD_SHARED =
