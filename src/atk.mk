# This file is part of MXE.
# See index.html for further information.

PKG             := atk
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.16.0
$(PKG)_CHECKSUM := 095f986060a6a0b22eb15eef84ae9f14a1cf8082488faa6886d94c37438ae562
$(PKG)_SUBDIR   := atk-$($(PKG)_VERSION)
$(PKG)_FILE     := atk-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := http://ftp.gnome.org/pub/gnome/sources/atk/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc gettext glib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://git.gnome.org/browse/atk/refs/tags' | \
    grep '<a href=' | \
    $(SED) -n "s,.*<a href='[^']*/tag/?id=ATK_\\([0-9]*_[0-9]*[02468]_[^<]*\\)'.*,\\1,p" | \
    $(SED) 's,_,.,g' | \
    head -1
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      mkdir -p '$(1).build'; \
      cd '$(1).build' && ../$(1)/configure \
          $(MXE_CONFIGURE_OPTS) \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
    if [ ! -e $(shell dirname $(1))/check_make_stamp ]; then \
      $(MAKE) -C '$(1).build' -j '$(JOBS)' $(MXE_DISABLE_CRUFT) SUBDIRS='atk po' SHELL=bash \
      && touch $(shell dirname $(1))/check_make_stamp; \
    fi
    if [ ! -e $(shell dirname $(1))/check_make_install_stamp ]; then \
      $(MAKE) -C '$(1).build' -j 1 install $(MXE_DISABLE_CRUFT) SUBDIRS='atk po' \
      && touch $(shell dirname $(1))/check_make_install_stamp; \
    fi
endef
