STAGING_DIR=$(STAGEDIR)

ifeq ($(or $(MT7986A),$(MT7986B)),y)
PREBUILT_DIR=$(shell pwd)/prebuilt-mt7986-ax6000
else ifeq ($(MT7981),y)
PREBUILT_DIR=$(shell pwd)/prebuilt-mt7981-ax3000
else
PREBUILT_DIR=$(shell pwd)/prebuilt
endif

PKG_BUILD_DIR=$(PREBUILT_DIR)

all:
ifeq ($(MT7981),y)
	install $(STAGING_DIR)/usr/lib/libmapd_interface_client.so $(PKG_BUILD_DIR)/libmapd_interface_client.so
endif

install: all
	install -D $(PREBUILT_DIR)/bs20 $(INSTALLDIR)/bin/bs20
	$(STRIP) $(INSTALLDIR)/bin/bs20
	chmod 0500 $(INSTALLDIR)/bin/bs20
	install -D $(PREBUILT_DIR)/mapd_cli $(INSTALLDIR)/bin/mapd_cli
	$(STRIP) $(INSTALLDIR)/bin/mapd_cli
	chmod 0500 $(INSTALLDIR)/bin/mapd_cli
ifeq ($(MT7981),y)
	install -D -m 755 $(PREBUILT_DIR)/libmapd_interface_client.so $(INSTALLDIR)/usr/lib/libmapd_interface_client.so
	$(STRIP) $(INSTALLDIR)/usr/lib/libmapd_interface_client.so
endif

clean:
	-rm -f $(EXEC) *.elf *.gdb *.o
