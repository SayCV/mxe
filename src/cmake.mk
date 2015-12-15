# This file is part of MXE.
# See index.html for further information.

PKG             := cmake
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 3.0.2
$(PKG)_CHECKSUM := 6b4ea61eadbbd9bec0ccb383c29d1f4496eacc121ef7acf37c7a24777805693e
$(PKG)_SUBDIR   := cmake-$($(PKG)_VERSION)
$(PKG)_FILE     := cmake-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://www.cmake.org/files/v$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_TARGETS  := $(BUILD)
$(PKG)_DEPS     :=

MSYS_PKGBUILD_DIR   = $(1)/../../../../qdev_home/MINGW-packages/mingw-w64-cmake

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://www.cmake.org/cmake/resources/software.html' | \
    $(SED) -n 's,.*cmake-\([0-9.]*\)\.tar.*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD_$(BUILD)
    cd $(1) && cd ${MSYS_PKGBUILD_DIR} && ls
    if [ ! -e $(1)/../check_patch_msys2_pkgbuild_stamp ]; then \
      if [ ! -e ${MSYS_PKGBUILD_DIR}/disable-response-files-for-msys.patch ]; then \
        cd $(1) && patch -p1 -i ${MSYS_PKGBUILD_DIR}/disable-response-files-for-msys.patch; \
      fi; \
      if [ ! -e ${MSYS_PKGBUILD_DIR}/dont-install-bundle.patch ]; then \
        cd $(1) && patch -p1 -i ${MSYS_PKGBUILD_DIR}/dont-install-bundle.patch; \
      fi; \
      touch $(1)/../check_patch_msys2_pkgbuild_stamp; \
    fi
    
    mkdir '$(1).build'
    # avoid configure executed via abs path.
    cd    '$(1).build' && '../$($(PKG)_SUBDIR)/configure' \
        --prefix='$(PREFIX)/$(TARGET)'
    $(MAKE) -C '$(1).build' -j '$(JOBS)'
    $(MAKE) -C '$(1).build' -j 1 install
endef
