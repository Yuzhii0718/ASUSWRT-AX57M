include ../common.mak

CFLAGS += $(if $(RTCONFIG_DEBUG),-g,-Os) -Wall $(EXTRACFLAGS) -fPIC
CFLAGS += -I. -I$(TOP)/shared -I$(SRCBASE)/include
CFLAGS += -I$(TOP)/openssl/include
ifeq ($(HND_ROUTER),y)
CFLAGS += -DHND_ROUTER
endif
ifeq ($(RTCONFIG_BCMARM),y)
CFLAGS += -I$(SRCBASE)/shared/bcmwifi/include -DTYPEDEF_FLOAT_T
endif
LDFLAGS += $(EXTRALDFLAGS) -L$(TOP_PLATFORM)/nvram${BCMEX}${EX7} -lnvram -L$(TOP)/shared -lshared
ifeq ($(RTCONFIG_BCM_502L07P2),y)
LDFLAGS += -L$(TOP_PLATFORM)/ethctl_lib -lethctl
endif
LDFLAGS += -lcrypt
LDFLAGS += -L$(TOP)/openssl -lcrypto -lssl

INSTALL = install

OBJS = openvpn_config.o openvpn_control.o openvpn_utils.o openvpn_options.o

ifeq ($(or $(MT7986A),$(MT7986B)),y)
PREBUILD_DIR=./prebuild-mt7986-ax6000
else ifeq ($(MT7981),y)
PREBUILD_DIR=./prebuild-mt7981-ax3000
else
PREBUILD_DIR=./prebuild
endif

ifneq ($(wildcard $(PREBUILD_DIR)/libvpn.so),)
all:
	cp -f $(PREBUILD_DIR)/libvpn.so .
else
all: libvpn.so

libvpn.so: $(OBJS)
	@echo " [libvpn] LD $@"
	@$(CC) $(LDFLAGS) -shared -o $@ $^
endif

install: all
	@echo " [libvpn] Installing as $(INSTALLDIR)/usr/lib/libvpn.so"
	@install -d $(INSTALLDIR)/usr/lib
	@install -m 755 libvpn.so $(INSTALLDIR)/usr/lib
	@$(if $(RTCONFIG_DEBUG),,$(STRIP) $(INSTALLDIR)/usr/lib/libvpn.so)

clean:
	rm -f *.o *.so *.a .*.depend *.prep

%.o: %.c .%.depend
	@echo " [libvpn] CC $@"
	@$(CC) $(CFLAGS) -o $@ -c $<

%.o: $(PREBUILD_DIR)/%.o
	@echo " [libvpn] cp $@"
	@cp -f $< $@

.depend: $(OBJS:%.o=%.c)
	@$(CC) $(CFLAGS) -M $^ > .depend

.%.depend: %.c
	@$(CC) $(CFLAGS) -M $< > $@

%.prep: %.c
	@$(CC) $(CFLAGS) -E $< > $@

-include $(OBJS:%.o=.%.depend)
