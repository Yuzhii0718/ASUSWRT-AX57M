STAGING_DIR=$(STAGEDIR)
PKG_BUILD_DIR=$(shell pwd)/prebuilt

all:
	install $(STAGING_DIR)/usr/lib/libmapd_interface_client.so  $(PKG_BUILD_DIR)/libmapd_interface_client.so

install: all
	install -D prebuilt/bs20 $(INSTALLDIR)/bin/bs20
	$(STRIP) $(INSTALLDIR)/bin/bs20
	chmod 0500 $(INSTALLDIR)/bin/bs20
	install -D prebuilt/mapd_cli $(INSTALLDIR)/bin/mapd_cli
	$(STRIP) $(INSTALLDIR)/bin/mapd_cli
	chmod 0500 $(INSTALLDIR)/bin/mapd_cli
	install -D -m 755 prebuilt/libmapd_interface_client.so $(INSTALLDIR)/usr/lib/libmapd_interface_client.so
	$(STRIP) $(INSTALLDIR)/usr/lib/libmapd_interface_client.so

clean:
	-rm -f $(EXEC) *.elf *.gdb *.o
