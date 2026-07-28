#***********************************************************************
#
# Makefile
#
#***********************************************************************
include $(LINUXDIR)/.config
include ../common.mak
include $(SRCBASE)/.config
include ../.config

ifneq ($(findstring CONFIG_BCM_KF_NETFILTER=, $(shell cat $(LINUXDIR)/.config)),)
ifneq ($(RTCONFIG_HND_ROUTER_AX_6756),y)
export CFLAGS += -DBCM_KF_NETFILTER
endif
endif

OBJS = webapi.o

ifeq ($(or $(MT7986A),$(MT7986B)),y)
PREBUILD_DIR=./prebuild-mt7986-ax6000
else ifeq ($(MT7981),y)
PREBUILD_DIR=./prebuild-mt7981-ax3000
else
PREBUILD_DIR=./prebuild
endif

OBJS += $(if $(wildcard priv_webapi.c), priv_webapi.o, $(PREBUILD_DIR)/priv_webapi.o)

CFLAGS += -Os -Wall $(EXTRACFLAGS) -fPIC
CFLAGS += -I. -I$(TOP)/shared -I$(SRCBASE)/include
CFLAGS += -I$(TOP)/json-c
CFLAGS += -I$(TOP)/httpd

ifeq ($(RTCONFIG_AIHOME_TUNNEL),y)
CFLAGS  += -I$(TOP)/aaews
endif

ifeq ($(RTCONFIG_BWDPI),y)
CFLAGS += -I$(TOP)/sqlite
CFLAGS += -I$(TOP)/bwdpi_source/src/tdts_udb_sample
CFLAGS += -I$(TOP)/bwdpi_source/src/tdts_udb_sample/linux
CFLAGS += -I$(TOP)/bwdpi_source/include
CFLAGS += -I$(TOP)/bwdpi_source/asus_include
endif

LDFLAGS += -L$(TOP)/json-c/.libs -ljson-c
LDFLAGS += -L$(TOP)/shared -lshared

ifeq ($(RTCONFIG_BWDPI),y)
LDFLAGS += -L$(TOP)/bwdpi_source/asus -lbwdpi
LDFLAGS += -L$(TOP)/bwdpi_source/asus_sql -lbwdpi_sql
LDFLAGS += -L$(TOP)/sqlite/.libs -lsqlite3
LDFLAGS += -lpthread
endif

ifeq ($(RTCONFIG_BCMARM),y)
CFLAGS += -I$(SRCBASE)/shared/bcmwifi/include -DTYPEDEF_FLOAT_T
endif

ifeq ($(RTCONFIG_CFGSYNC),y)
CFLAGS += -I$(TOP)/shared/sysdeps/amas
CFLAGS += -I$(TOP)/cfg_mnt
LIBS += -L$(TOP)/cfg_mnt -lcfgmnt
endif

ifeq ($(RTCONFIG_TRUSTZONE), y)
CFLAGS += -I$(TOP)/ateed/
LIBS += -L$(TOP)/ateed/ -latee
endif

ifeq ($(HND_ROUTER_BE_4916), y)
CFLAGS+= -fcommon
endif

ifeq ($(RTCONFIG_HTTPS),y)
CFLAGS += -I$(TOP)/mssl
CFLAGS += -I$(TOP)/openssl/include
LIBS += -L$(TOP)/mssl -lmssl
LIBS += -L$(TOP)/openssl -lssl -lcrypto -ldl
endif

ifeq ($(RTCONFIG_USB),y)
CFLAGS += -I$(TOP)/libdisk
LIBS += -L$(TOP)/libdisk -ldisk
ifeq ($(RTCONFIG_USB_SMS_MODEM),y)
CFLAGS += -I$(TOP)/smspdu
LIBS += -L$(TOP)/smspdu -lsmspdu
endif
endif

ifeq ($(BRCM_CHIP),6813)
CFLAGS += -DCHIP_BCM4916
endif

all: libwebapi.so

# handle prebuilt object here.
# FORCE ensures re-copy on every build — git timestamps on prebuilt files
# are old (clone date), so a normal dependency would skip the copy after
# the first build, leaving stale objects from a different platform.
ifneq ($(wildcard $(PREBUILD_DIR)),)
priv_webapi.o: FORCE
	@cp -f $(PREBUILD_DIR)/priv_webapi.o $@
endif
FORCE:

.c.o:
	$(CC) -c $*.c $(CFLAGS)

libwebapi.so: $(OBJS)
	$(CC) -shared $(OBJS) $(LDFLAGS) -o libwebapi.so

.PHONY: clean
clean:
	@echo LINUXDIR=$(LINUXDIR)
	-rm -rf libwebapi.so webapi.o $(OBJS)

