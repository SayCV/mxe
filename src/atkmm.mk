# This file is part of MXE.
# See index.html for further information.

PKG             := atkmm
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.22.7
$(PKG)_CHECKSUM := bfbf846b409b4c5eb3a52fa32a13d86936021969406b3dcafd4dd05abd70f91b
$(PKG)_SUBDIR   := atkmm-$($(PKG)_VERSION)
$(PKG)_FILE     := atkmm-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://ftp.gnome.org/pub/gnome/sources/atkmm/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc atk glibmm

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://git.gnome.org/browse/atkmm/refs/tags' | \
    grep '<a href=' | \
    $(SED) -n 's,.*<a[^>]*>\([0-9][^<]*\)<.*,\1,p' | \
    head -1
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      mkdir -p '$(1).build'; \
      cd '$(1).build' && ../$(1)/configure \
          $(MXE_CONFIGURE_OPTS) \
          MAKE=$(MAKE) \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
    if [ ! -e $(shell dirname $(1))/check_make_stamp ]; then \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= \
      && touch $(shell dirname $(1))/check_make_stamp; \
    fi
    if [ ! -e $(shell dirname $(1))/check_make_install_stamp ]; then \
      $(MAKE) -C '$(1).build' -j 1 install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= \
      && touch $(shell dirname $(1))/check_make_install_stamp; \
    fi
endef
