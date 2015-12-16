# This file is part of MXE.
# See index.html for further information.

PKG             := aubio
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.4.2
$(PKG)_CHECKSUM := 1cc58e0fed2b9468305b198ad06b889f228b797a082c2ede716dc30fcb4f8f1f
$(PKG)_SUBDIR   := aubio-$($(PKG)_VERSION)
$(PKG)_FILE     := aubio-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := http://www.aubio.org/pub/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc ffmpeg fftw jack libsamplerate libsndfile

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.aubio.org/download' | \
    $(SED) -n 's,.*aubio-\([0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_CONFIGURE
    @if [ ! -e $(2)/check_configure_stamp ]; then \
      mkdir -p '$(1).build'; \
      cd '$(1).build' && \
          AR='$(TARGET)-ar'                         \
        CC='$(TARGET)-gcc'                        \
        PKGCONFIG='$(TARGET)-pkg-config'          \
        ../$(1)/waf configure                           \
            -j '$(JOBS)'                          \
            --with-target-platform='win$(BITS)'   \
            --prefix='$(PREFIX)/$(TARGET)'        \
            --enable-fftw3f                       \
            $(if $(BUILD_STATIC),                 \
                --enable-static --disable-shared, \
                --disable-static --enable-shared) \
      && touch $(2)/check_configure_stamp; \
      rm -rf $(2)/check_make_stamp >/dev/null 2>&1; \
      rm -rf $(2)/check_make_install_stamp >/dev/null 2>&1; \
    fi
endef

define $(PKG)_BUILD
    $(call $(PKG)_CONFIGURE,$(1),$(shell dirname $(1)))

    # disable txt2man and doxygen
    $(SED) -i '/\(TXT2MAN\|DOXYGEN\)/d' '$(1)/build/c4che/_cache.py'
    
    if [ ! -e $(shell dirname $(1))/check_make_install_stamp ]; then \
      cd '$(1).build' && ../$(1)/waf build install \
      && touch $(shell dirname $(1))/check_make_install_stamp; \
    fi

    # It is not trivial to adjust the installation in waf-based builds
    $(if $(BUILD_STATIC),                         \
        $(INSTALL) -m644 '$(1)/build/src/libaubio.a' '$(PREFIX)/$(TARGET)/lib')

    '$(TARGET)-gcc'                               \
        -W -Wall -Werror -ansi -pedantic          \
        '$(2).c' -o '$(PREFIX)/$(TARGET)/bin/test-aubio.exe' \
        `'$(TARGET)-pkg-config' aubio --cflags --libs`
endef
