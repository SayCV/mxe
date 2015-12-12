# This file is part of MXE.
# See index.html for further information.

PKG             := binutils
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.25.1
$(PKG)_CHECKSUM := b5b14added7d78a8d1ca70b5cb75fef57ce2197264f4f5835326b0df22ac9f22
$(PKG)_SUBDIR   := binutils-$($(PKG)_VERSION)
$(PKG)_FILE     := binutils-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := http://ftp.gnu.org/pub/gnu/binutils/$($(PKG)_FILE)
$(PKG)_URL_2    := ftp://ftp.cs.tu-berlin.de/pub/gnu/binutils/$($(PKG)_FILE)
$(PKG)_DEPS     := pkgconf

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://ftp.gnu.org/gnu/binutils/?C=M;O=D' | \
    $(SED) -n 's,.*<a href="binutils-\([0-9][^"]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      cd '$(1)' && './configure' \
          --target='$(TARGET)' \
          --build='$(BUILD)' \
          --prefix='$(PREFIX)' \
          --disable-multilib \
          --with-gcc \
          --with-gnu-ld \
          --with-gnu-as \
          --disable-nls \
          --disable-shared \
          --disable-werror \
      && touch $(2)/check_configure_stamp; \
    fi
endef

define $(PKG)_BUILD
    mkdir -p '$(1).build'
	  
  	$(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))
	  
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install

    rm -f $(addprefix $(PREFIX)/$(TARGET)/bin/, ar as dlltool ld ld.bfd nm objcopy objdump ranlib strip)
endef

$(PKG)_BUILD_$(BUILD) :=
