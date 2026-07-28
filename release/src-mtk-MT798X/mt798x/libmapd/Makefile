LINUX_VERSION=$(LINUX_KERNEL)
INSTALLKMODDIR:=$(INSTALLDIR)/lib/modules/$(LINUX_VERSION)

PBBINS=$(wildcard prebuilt/*)
LIBS=$(filter %.so,$(PBBINS))
KMOD=$(filter %.ko,$(PBBINS))
EXEC=$(filter-out $(LIBS) $(KMOD),$(PBBINS))
STAGING_DIR=$(STAGEDIR)
PKG_BUILD_DIR=$(shell pwd)/prebuilt

all:
	[ -d $(STAGING_DIR)/usr/lib ] || install -d $(STAGING_DIR)/usr/lib
	install -m 755 $(PKG_BUILD_DIR)/libmapd_interface_client.so* $(STAGING_DIR)/usr/lib

install: all
	@[ -d $(INSTALLDIR)/usr/lib ] || install -d $(INSTALLDIR)/usr/lib
	@for i in $(LIBS); do install -D $$i $(INSTALLDIR)/usr/lib ; done
#	@$(STRIP) $(INSTALLDIR)/usr/lib/*
#	@[ -d $(INSTALLKMODDIR) ] || install -d $(INSTALLKMODDIR)
#	@for i in $(KMOD); do install -D $$i $(INSTALLKMODDIR) ; done
#	@$(KSTRIPX) $(INSTALLKMODDIR)/*.ko
#	@[ -d $(INSTALLDIR)/usr/bin ] || install -d $(INSTALLDIR)/usr/bin
#	@for i in $(EXEC); do install -D $$i $(INSTALLDIR)/usr/bin ; done
#	@$(STRIP) $(INSTALLDIR)/usr/bin/*

clean:

stage:
