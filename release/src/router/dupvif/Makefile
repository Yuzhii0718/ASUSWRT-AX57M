LINUX_VERSION=$(LINUX_KERNEL)
INSTALLKMODDIR:=$(INSTALLDIR)/lib/modules/$(LINUX_VERSION)

ifeq ($(or $(MT7986A),$(MT7986B)),y)
PREBUILD_DIR=prebuild-mt7986-ax6000
else ifeq ($(MT7981),y)
PREBUILD_DIR=prebuild-mt7981-ax3000
else
PREBUILD_DIR=prebuild
endif

PBBINS=$(wildcard $(PREBUILD_DIR)/*)
LIBS=$(filter %.so,$(PBBINS))
KMOD=$(filter %.ko,$(PBBINS))
EXEC=$(filter-out $(LIBS) $(KMOD),$(PBBINS))

all:

install:
#	@[ -d $(INSTALLDIR)/usr/lib ] || install -d $(INSTALLDIR)/usr/lib
#	@for i in $(LIBS); do install -D $$i $(INSTALLDIR)/usr/lib ; done
#	@$(STRIP) $(INSTALLDIR)/usr/lib/*
	@[ -d $(INSTALLKMODDIR) ] || install -d $(INSTALLKMODDIR)
	@for i in $(KMOD); do install -D $$i $(INSTALLKMODDIR) ; done
	@$(STRIPX) $(INSTALLKMODDIR)/*.ko
#	@[ -d $(INSTALLDIR)/usr/bin ] || install -d $(INSTALLDIR)/usr/bin
#	@for i in $(EXEC); do install -D $$i $(INSTALLDIR)/usr/bin ; done
#	@$(STRIP) $(INSTALLDIR)/usr/bin/*

clean:

stage:
