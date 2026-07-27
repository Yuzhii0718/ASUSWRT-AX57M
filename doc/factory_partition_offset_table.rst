================================================================================
MT798X Factory Partition Offset Table
================================================================================

:Author: ASUSWRT-MT798X Project
:Date:   2026-07-27
:Device: ZBTlink ZBT-Z8103AX-C (RT-8103AX, MT7981 SoC, SPI-NAND 128MB W25N01GV)
:Scope:  MT798X platform (RTCONFIG_MT798X) — RT8103AX, RT4GAX56, RTAX53U, RTAX54,
         XD4S, and derivative models

.. contents:: Table of Contents
   :depth: 3
   :local:

--------------------------------------------------------------------------------
1. Overview
--------------------------------------------------------------------------------

The Factory partition (MTD2, 2 MB = 0x200000) on SPI-NAND stores three categories
of data:

1. **MAC addresses and EEPROM header** at the very beginning (``0x00000``–``0x0002A``).
2. **WiFi RF calibration data** (``0x00040``–``0x00FFF``), proprietary MediaTek
   EEPROM BIN format consumed directly by the WiFi driver.
3. **ASUS board parameters** at a high-offset block (``0x0B0000``–``0x0BFFFF``),
   read by the RC daemon via :c:func:`FRead`.

The MAC/EEPROM area uses **Flash-absolute addresses** (``OFFSET_MTD_FACTORY +
offset``), while the ASUS parameter block shifts from that base by
``FTRY_PARM_SHIFT = 0xB0000``.

This document enumerates every defined offset, its data type, the corresponding
C macro, the source files that read or write it, and — where available — the
actual byte values found on a production ZBT-Z8103AX-C device.

--------------------------------------------------------------------------------
2. Base Constants
--------------------------------------------------------------------------------

.. list-table:: Platform base constants (MT798X only)
   :header-rows: 1

   * - Constant
     - Value
     - Defined at
     - Description
   * - ``OFFSET_MTD_FACTORY``
     - ``0x40000``
     - ``ralink.h:764``
     - Flash-absolute base address of the Factory MTD partition
   * - ``OFFSET_EEPROM_VER``
     - ``0x40002``
     - ``ralink.h:765``
     - EEPROM format version (2 bytes)
   * - ``FTRY_PARM_SHIFT``
     - ``0xB0000``
     - ``ralink.h:767``
     - Offset from ``OFFSET_MTD_FACTORY`` to the ASUS parameter block.
       Pads the gap between the EEPROM data (first 4 KB) and the board
       parameters so that the parameter block sits at a clean
       NAND-page-aligned address.
   * - ``SPI_PARALLEL_NOR_FLASH_FACTORY_LENGTH``
     - ``0x120000``
     - ``ralink.h:755``
     - Total usable Factory size (covers all offsets up to SERIAL_NUMBER)

**Address calculation**::

   FRead_absolute = OFFSET_MTD_FACTORY + FTRY_PARM_SHIFT + offset_in_block
                  = 0x40000     + 0xB0000         + offset_in_block
                  = 0xF0000     + offset_in_block

   Factory_internal_offset = FRead_absolute - OFFSET_MTD_FACTORY
                           = 0xB0000 + offset_in_block

--------------------------------------------------------------------------------
3. Factory Partition Layout
--------------------------------------------------------------------------------

.. code-block:: text

   Factory partition (MTD2, 2048 KB = 0x200000)
   ┌──────────────────────────────────────────────────────────────────┐
   │ 0x000000 ~ 0x000FFF   (4 KB)     EEPROM header + MAC + RF Cal.   │
   │   ├── 0x00000: EEPROM Signature "81 79"                         │
   │   ├── 0x00002: EEPROM Version                                   │
   │   ├── 0x00004: WiFi Base MAC (2.4G)                             │
   │   ├── 0x0000A: Reserved (MAC+1 on some OEM data)                │
   │   ├── 0x00024: WAN MAC (eth1)                                   │
   │   ├── 0x0002A: LAN MAC (br-lan / GMAC0)                        │
   │   ├── 0x00040~0x00D80:  RF calibration tables (details below)   │
   │   └── 0x00D80~0x00FFF:  End-of-block padding                    │
   ├──────────────────────────────────────────────────────────────────┤
   │ 0x010000 ~ 0x09FFFF   (~576 KB)  2.4G / 5G RF calibration BIN      │
   │   Used by older multi-chip platforms (e.g. MT7615, MT7915D) where    │
   │   2.4G and 5G EEPROM BINs reside at separate offsets (typically      │
   │   0x0000 and 0x8000). On MT7981 with integrated WiFi, the entire     │
   │   calibration fits in the first 4 KB; this region is all 0xFF.       │
   │   init_wl() uses dd bs=655360 as a safety margin for compatibility.  │
   ├──────────────────────────────────────────────────────────────────┤
   │ 0x0A0000 ~ 0x0AFFFF   (64 KB)    Gap (NAND erase state = 0xFF)  │
   ├──────────────────────────────────────────────────────────────────┤
   │ 0x0B0000 ~ 0x0BFFFF   (64 KB)    ASUS Board Parameter Block      │
   │   ├── 0x0B0180: WPS PIN Code                                    │
   │   ├── 0x0B0188: Country Code                                    │
   │   ├── 0x0B018A: Bootloader Version                              │
   │   ├── 0x0B0234: REG2G_EEPROM_ADDR (2.4G calibration pointer)    │
   │   ├── 0x0B023E: REG5G_EEPROM_ADDR (5G calibration pointer)      │
   │   ├── 0x0B0248: REGSPEC_ADDR (regulatory domain pointer)        │
   │   ├── 0x0BDD00: AiMesh Bundle Key                               │
   │   ├── 0x0BDD20: AiMesh Bundle Flag                              │
   │   ├── 0x0BDDF0: ASUSCTRL Flags                                  │
   │   ├── 0x0BDDF8: ASUSCTRL Change SKU                             │
   │   ├── 0x0BDEE0: Encrypted Password                              │
   │   ├── 0x0BFE00: Hardware ID (HwId)                              │
   │   ├── 0x0BFE04: Hardware Version (HwVer)                        │
   │   ├── 0x0BFE0C: Hardware BOM                                    │
   │   ├── 0x0BFE3E: Date Code (YYYYMMDD)                            │
   │   ├── 0x0BFE46: Co-Brand Flag                                   │
   │   ├── 0x0BFE47: FCO Flag                                        │
   │   ├── 0x0BFF30: Custom LAN IP (ATE use)                         │
   │   ├── 0x0BFF50: Plaintext Password                              │
   │   ├── 0x0BFF70: EISN (Encrypted Individual Serial Number)       │
   │   ├── 0x0BFF80: WiFi Pre-Shared Key (PSK)                       │
   │   ├── 0x0BFF90: Territory Code                                  │
   │   ├── 0x0BFFA0: Device Flags                                    │
   │   ├── 0x0BFFB0: ODM Product ID                                  │
   │   ├── 0x0BFFC0: Failure Retry Counter                           │
   │   ├── 0x0BFFD0: Boot Failure Log Pointer                        │
   │   ├── 0x0BFFE0: Device Failure Log Pointer                      │
   │   └── 0x0BFFF0: Serial Number                                   │
   ├──────────────────────────────────────────────────────────────────┤
   │ 0x0C0000 ~ 0x11FFFF   (384 KB)   Unused / padding               │
   ├──────────────────────────────────────────────────────────────────┤
   │ 0x120000 ~ 0x1FFFFF   (896 KB)   Outside usable range           │
   └──────────────────────────────────────────────────────────────────┘

.. note::

   The usable range defined by ``SPI_PARALLEL_NOR_FLASH_FACTORY_LENGTH``
   (``0x120000``) ends at ``OFFSET_SERIAL_NUMBER + 32`` = ``0x120010``.
   Anything above ``0x120000`` is not read by ASUSWRT.

--------------------------------------------------------------------------------
4. Group 1: EEPROM Header & MAC Addresses
--------------------------------------------------------------------------------

These offsets are at the very beginning of the Factory partition and are read
using **Flash-absolute addresses** (no ``FTRY_PARM_SHIFT``). On MT798X, four
MAC slots are defined; a fifth slot at ``0x0A`` is reserved (present on some
OEM data but not referenced by any C macro).

.. list-table:: EEPROM header and MAC address offsets
   :header-rows: 1
   :widths: 8,8,10,6,20,16,32

   * - Factory Offset
     - C Macro (ralink.h)
     - Value (HEX)
     - Size
     - Description
     - ZBT Binary Value (hexdump)
     - Source Files
   * - ``0x00000``
     - *(none / inline)*
     - ``0x40000``
     - 2 B
     - EEPROM signature magic. Must be ``0x8179`` for a
       valid MediaTek EEPROM BIN.
     - ``81 79``
     - Driver: MTK WiFi firmware loader
       (checks header before parsing)
   * - ``0x00002``
     - ``OFFSET_EEPROM_VER``
     - ``0x40002``
     - 2 B
     - EEPROM format version number.
     - ``00 00`` (version 0)
     - ``ralink.h:765``
   * - ``0x00004``
     - ``OFFSET_MAC_ADDR_2G``
       (also ``OFFSET_MAC_ADDR``)
     - ``0x40004``
     - 6 B
     - **WiFi Base MAC address**. Used as the 2.4 GHz
       radio MAC by the MTK driver.
       On MT798X, ``OFFSET_MAC_ADDR`` is a direct alias
       of ``OFFSET_MAC_ADDR_2G``; the 5 GHz MAC is
       auto-derived by the driver (base[0] += 2).

       Read at boot by :c:func:`init_syspara` via
       ``FRead(OFFSET_MAC_ADDR, ...)``.
     - ``f8:5e:3c:69:b3:c6``
     - | ``ralink.h:832-833``
       | ``init-ralink.c:2290``
       | Driver: ``e2p`` offset 0x4 (direct MTD read)
   * - ``0x0000A``
     - *(none — reserved)*
     - ``0x4000A``
     - 6 B
     - **Reserved 5th MAC slot**. Not referenced by any
       ASUSWRT macro. On the ZBT binary it contains
       ``base + 1`` (``b3:c7``). The driver does not
       read this field.
     - ``f8:5e:3c:69:b3:c7``
     - (unused)
   * - ``0x00024``
     - ``OFFSET_MAC_GMAC1``
     - ``0x40024``
     - 6 B
     - **WAN MAC address** (eth1). Read at boot, set
       as ``et1macaddr`` in NVRAM via
       :c:func:`set_et0macaddr(macaddr2, ...)`.
     - ``f8:5e:3c:69:b3:c9``
     - | ``ralink.h:834``
       | ``init-ralink.c:2297``
       | ``set_et0macaddr()`` in ``init-ralink.c:1968``
   * - ``0x0002A``
     - ``OFFSET_MAC_GMAC0``
     - ``0x4002A``
     - 6 B
     - **LAN MAC address** (br-lan / GMAC0).
       Set as ``et0macaddr`` in NVRAM.
     - ``f8:5e:3c:69:b3:c8``
     - | ``ralink.h:835``
       | ``init-ralink.c:2295``

MAC derivation logic (MT798X)::

   Factory 0x04  →  2.4G WiFi  = base MAC                   (driver direct)
   Factory 0x04  →  5G WiFi    = base[0] + 2                (driver auto)
   Factory 0x2A  →  LAN GMAC   = OFFSET_MAC_GMAC0           (init_syspara)
   Factory 0x24  →  WAN eth1   = OFFSET_MAC_GMAC1           (init_syspara)



5G MAC derivation in driver
   The MTK driver reads ``e2p`` offset 0x4 as the base MAC for 2.4 GHz and
   derives 5 GHz by adding 2 to the first octet:

   .. code-block:: text

      2.4G:  F8:5E:3C:69:B3:C6
      5G:    FA:5E:3C:69:B3:C6  (0xF8 + 0x02 = 0xFA)

   This is a hard-coded driver convention and is **not** controlled by any
   Factory macro or NVRAM variable.

--------------------------------------------------------------------------------
5. Group 2: WiFi RF Calibration Data
--------------------------------------------------------------------------------

For MT7981, the entire RF calibration fits within a single 4 KB block
(``0x00040``–``0x00FFF``). The remaining 636 KB (``0x001000``–``0x09FFFF``)
are all ``0xFF`` (NAND erase state, unused). This is in contrast to older
multi-chip platforms (e.g. MT7915D) where 2.4G and 5G calibration BINs
resided at separate offsets (typically ``0x0000`` and ``0x8000``).

.. list-table:: Calibration data region (Factory 0x00040 – 0x00FFF, MT798X)
   :header-rows: 1
   :widths: 10,10,8,30,42

   * - Factory Offset
     - Size
     - ZBT Status
     - Description
     - Notes
   * - ``0x00040``
     - variable
     - ✅ populated
     - **PA/LNA configuration & general settings.**
       Indicates internal vs. external FEM and basic
       radio config.
     - ``0x00244``: ``a6 a5 a1 a1`` — PA type
       indicators for iPAiLNA.
   * - ``0x00270``
     - ``~0x310``
     - ✅ populated
     - **5 GHz per-channel TX power table (group 0).**
       Contains calibrated TX power offsets for each
       5 GHz channel.
     - Starts at ``0x00270`` with ``0c 00 00 00``
       (group count header).
   * - ``0x003E0``
     - ``~0x80``
     - ✅ populated
     - **TX power general parameters.** Channel count,
       bandwidth flags, per-chip tuning values.
     - ``0x003e0``: ``00 00 00 00 00 00 00 00 12 12 12``
   * - ``0x003F0``
     - ``~0x20``
     - ✅ populated
     - **Stream mapping and antenna config.** Encodes
       TX/RX stream count and antenna numbering.
     - ``0x003f0``: ``22 22 22 22 33 33 33 33 33 33...``
   * - ``0x00440``
     - variable
     - ✅ populated
     - **2.4 GHz per-channel TX power offsets.**
       Array of per-channel dB offsets for 2.4 GHz band.
     - ``0x00440``: ``00 26 26 29 29 26 26...``
   * - ``0x00460``
     - variable
     - ✅ populated
     - **5 GHz per-channel TX power offsets (group 1).**
       Second group of 5 GHz channel power data.
     - ``0x00460``: ``00 24 24 24 24 22 22...``
   * - ``0x00490``
     - variable
     - ✅ populated
     - **Target power / backoff table.** Global power
       backoff configuration.
     - ``0x00490``: ``00 80 80 80 80 81 81...``
   * - ``0x004A0``
     - variable
     - ✅ populated
     - **Per-rate power delta table.** TX power offsets
       per MCS / data rate.
     - ``0x004a0``: ``00 c5 c3 c4 c5 c6 c4 c4 c5...``
   * - ``0x00540``
     - ``~0x40``
     - ✅ populated
     - **Internal power calibration adjustment.**
       ``0x00548``: ``3d`` — mid-point power reference.
     -
   * - ``0x00580``
     - ``~0x50``
     - ✅ populated
     - **2.4 GHz thermal compensation table.**
       TX power adjustment vs. temperature for 2.4G.
     - ``0x00580``: ``00 7f 7f 7f d1 d1 dd dd e9 e9 f5 f5...``
   * - ``0x00600``
     - ``~0x190``
     - ✅ populated
     - **5 GHz thermal compensation table.**
       TX power adjustment vs. temperature for 5G.
     - ``0x00600``: ``1c f2 fc 00 00 00...``
   * - ``0x00790``
     - ``~0x140``
     - ✅ populated
     - **2.4 GHz per-rate TX power tables.** Detailed
       power values per MCS index, bandwidth, and NSS.
     - ``0x00790``: ``02 1e 02 1e 02 00 02 00 02 37 02 37...``
   * - ``0x00990``
     - ``~0x50``
     - ✅ populated
     - **5 GHz per-rate TX power tables.** Similar
       structure to 2.4 GHz group.
     - ``0x00990``: ``00 ae 00 00 00 ae 00 00 00 d4...``
   * - ``0x00A20``
     - ``~0x80``
     - ✅ populated
     - **Per-channel RSSI offset table.**
       Receiver sensitivity calibration per channel.
     - ``0x00a20``: ``00 49 52 56 55 55 55 55...``
   * - ``0x00B10``
     - ``~0x20``
     - ✅ populated
     - **Thermal compensation tail / extension.**
       Continuation of thermal tables.
     - ``0x00b10``: ``d1 d1 dd dd e9 e9 f5 f5 fd fd 14 14 1d 1d...``
   * - ``0x00CA0``
     - ``~0x80``
     - ✅ populated
     - **Reserved / manufacturer-specific data.**
       May contain production tracking or additional
       calibration metadata.
     - ``0x00ca0``: ``83 84 00 00 c3 c4 c3 82 82 82 81 c1 c4 c5 c4 00...``
   * - ``0x00D00``
     - ``~0xFF``
     - ✅ populated
     - **Reserved calibration tail.** Remaining
       calibration parameters before end of 4KB block.
     - ``0x00d00``: ``c0 bb c0 bb c0 bb c0 bb 40 c5 c0 c4 c0 c3 c0 c3...``

.. important::

   The exact structure and encoding of the EEPROM BIN (offsets ``0x00040``
   through ``0x00FFF``) is **proprietary to MediaTek** and is documented in
   the MT7981 Wi-Fi driver source (``mtwifi`` / ``mt_wifi`` module). The
   offsets listed above are empirically derived from the ZBT-Z8103AX-C
   reference binary and are subject to revision per chip stepping.

   The MTK WiFi driver reads this data directly from ``/tmp/e2p``, which is
   a copy of the first 640 KB of the Factory partition prepared by
   :c:func:`init_wl` in ``init-ralink.c``.

--------------------------------------------------------------------------------
6. Group 3: ASUS Board Parameters
--------------------------------------------------------------------------------

The ASUS parameter block starts at :math:`\text{FactoryOffset} = 0xB0000 +
\text{offsetWithinBlock}` and is accessed via :c:func:`FRead` using the
computed ``OFFSET_MTD_FACTORY + FTRY_PARM_SHIFT + offset`` absolute address.

All macros in this section are defined in ``ralink.h`` (lines 927–944 for the
generic/default/MT798X path).

6.1 System Identification
~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Hardware identity fields
   :header-rows: 1
   :widths: 8,22,6,24,40

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0BFE00``
     - ``OFFSET_HWID``
     - 4 B
     - **Hardware ID** (e.g. ``"HL"``).
       Used to select the correct device-specific
       code paths.
     - | ``ralink.h:939``
       | Read in ``init_syspara()`` (``init-ralink.c:2097``)
       | Fallback: ``"UNKN"`` → treated as dev board
   * - ``0x0BFE04``
     - ``OFFSET_HW_VERSION``
     - 8 B
     - **Hardware version** string (e.g. ``"1.0"``).
     - | ``ralink.h:940``
       | Read in ``init_syspara()`` (``init-ralink.c:2098``)
   * - ``0x0BFE0C``
     - ``OFFSET_HW_BOM``
     - 32 B
     - **BOM (Bill of Materials) revision**.
       Tracks component changes across production
       batches.
     - | ``ralink.h:941``
       | Read in ``init_syspara()`` (``init-ralink.c:2099``)
   * - ``0x0BFE3E``
     - ``OFFSET_HW_DATE_CODE``
     - 8 B
     - **Production date code**, format ``YYYYMMDD``
       (e.g. ``"20250101"``).
     - | ``ralink.h:942``
       | Read in ``init_syspara()`` (``init-ralink.c:2100``)
   * - ``0x0BFE46``
     - ``OFFSET_HW_COBRAND``
     - 1 B
     - **Co-brand flag.** Non-zero if the device is a
       co-branded SKU (e.g. Best Buy, carrier variant).
     - | ``ralink.h:943``
   * - ``0x0BFE47``
     - ``OFFSET_FCO``
     - 1 B
     - **FCO (Factory Configuration Option) flag.**
       Controls factory-default behavior variants.
     - | ``ralink.h:944``
   * - ``0x0BFFF0``
     - ``OFFSET_SERIAL_NUMBER``
     - 32 B
     - **Device serial number.** Used for DDNS,
       Let's Encrypt, AiMesh binding, warranty lookup.
     - | ``ralink.h:936``
       | ``init-ralink.c:2444``
       | Fallback: ``"DEV-RT-8103AX"``
   * - ``0x0BFFB0``
     - ``OFFSET_ODMPID``
     - 16 B
     - **ODM Product ID / shown model name.** Overrides
       the model name displayed in the Web UI for
       retail-specific SKUs (e.g. Best Buy).
     - | ``ralink.h:932``

6.2 Regulatory & Region
~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Region configuration fields
   :header-rows: 1
   :widths: 8,22,6,24,40

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0B0188``
     - ``OFFSET_COUNTRY_CODE``
     - 2 B
     - **Country code** (numeric ISO).
     - | ``ralink.h:787``
   * - ``0x0BFF90``
     - ``OFFSET_TERRITORY_CODE``
     - 5 B
     - **Territory / region code**, format ``XX/NN``
       (e.g. ``"CN/01"``, ``"US/01"``, ``"TW/01"``).
       Determines allowed WiFi channels and TX power
       limits per regulatory domain.
     - | ``ralink.h:930``
       | ``init-ralink.c:2440``
       | Fallback: ``"DB/01"`` (Germany) if blank
   * - ``0x0B0248``
     - ``REGSPEC_ADDR``
     - 4 B
     - **Regulatory specification data pointer.**
       Points to custom regulatory domain definitions.
     - | ``ralink.h:868``
       | Requires ``RTCONFIG_NEW_REGULATION_DOMAIN``

6.3 EEPROM Calibration Pointers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These fields tell ASUSWRT where the WiFi calibration BINs are located inside
the Factory partition. They are critical for the Wi-Fi driver to find
calibration data when it is stored at non-zero offsets (e.g., separate 2.4G
and 5G BIN regions on NOR flash layout).

.. list-table:: EEPROM pointer fields
   :header-rows: 1
   :widths: 8,22,6,30,34

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0B0234``
     - ``REG2G_EEPROM_ADDR``
     - 10 B
     - Pointer to the 2.4 GHz EEPROM BIN within the
       Factory partition. Format: decimal-offset string
       (e.g. ``"0"`` for offset 0).
     - | ``ralink.h:866``
       | ``init-ralink.c:2256``
       | Requires ``RTCONFIG_NEW_REGULATION_DOMAIN``
       | If blank, driver uses default built-in BIN
   * - ``0x0B023E``
     - ``REG5G_EEPROM_ADDR``
     - 10 B
     - Pointer to the 5 GHz EEPROM BIN within the
       Factory partition. Same format as 2.4G above.
     - | ``ralink.h:867``
       | ``init-ralink.c:2267``
       | Requires ``RTCONFIG_NEW_REGULATION_DOMAIN``

.. note::

   On MT798X, the calibration data is a unified BIN at Factory offset 0,
   so both pointers should be set to ``"0"``. The pointer mechanism exists
   for legacy NOR flash platforms that stored 2.4G and 5G EEPROM BINs at
   different physical offsets (e.g., 2.4G at offset 0, 5G at offset 0x8000).

6.4 Security & Credentials
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Security-related fields
   :header-rows: 1
   :widths: 8,22,6,28,36

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0B0180``
     - ``OFFSET_PIN_CODE``
     - 8 B
     - **WPS PIN code.** Factory-assigned 8-digit
       PIN for Wi-Fi Protected Setup.
     - | ``ralink.h:786``
   * - ``0x0BFF50``
     - ``OFFSET_PASS``
     - 32 B
     - **Plaintext password.** Default admin or
       device-level password (legacy, eventually
       replaced by PASS_ENC).
     - | ``ralink.h:928``
       | Superseded by ``OFFSET_PASS_ENC`` when
         ``RTCONFIG_PASS_V2`` is enabled.
   * - ``0x0BDEE0``
     - ``OFFSET_PASS_ENC``
     - 64 B
     - **Encrypted password** (PASS_V2 format).
       Uses an encryption scheme to protect
       the device-level password at rest.
     - | ``ralink.h:927``
       | Active when ``RTCONFIG_PASS_V2`` is defined.
   * - ``0x0BFF70``
     - ``OFFSET_EISN``
     - 32 B
     - **Encrypted Individual Serial Number.**
       Obfuscated / encrypted copy of the serial
       number for anti-tampering checks.
     - | ``ralink.h:929``
   * - ``0x0BFF80``
     - ``OFFSET_PSK``
     - 14 B
     - **Default WiFi Pre-Shared Key (PSK).**
       Factory-preset Wi-Fi password printed on
       the device label.
     - | ``ralink.h:881``

6.5 AiMesh (ASUS Mesh)
~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: AiMesh-specific fields
   :header-rows: 1
   :widths: 8,22,6,30,34

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0BDD00``
     - ``OFFSET_AMAS_BUNDLE_KEY``
     - 32 B
     - **AiMesh bundle encryption key.** Used for
       secure pairing between AiMesh nodes.
     - | ``ralink.h:950``
       | Requires ``RTCONFIG_AMAS``
   * - ``0x0BDD20``
     - ``OFFSET_AMAS_BUNDLE_FLAG``
     - 32 B
     - **AiMesh bundle flag.** Indicates the AiMesh
       pairing status and mode (router vs. node).
     - | ``ralink.h:949``
       | Requires ``RTCONFIG_AMAS``

6.6 ASUSCTRL (Remote Management)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: ASUSCTRL fields
   :header-rows: 1
   :widths: 8,22,6,30,34

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0BDDF0``
     - ``OFFSET_ASUSCTRL_FLAGS``
     - 8 B
     - **ASUSCTRL control flags.** Remote management
       and cloud connectivity configuration bits.
     - | ``ralink.h:969``
       | Requires ``RTCONFIG_ASUSCTRL``
   * - ``0x0BDDF8``
     - ``OFFSET_ASUSCTRL_CHG_SKU``
     - 2 B
     - **ASUSCTRL SKU change record.** Tracks if the
       device SKU has been changed for cloud service
       provisioning.
     - | ``ralink.h:971``
       | Requires ``RTCONFIG_ASUSCTRL``

6.7 Failure / Diagnostic Logging
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Diagnostic and failure-logging fields
   :header-rows: 1
   :widths: 8,22,6,32,32

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0BFFC0``
     - ``OFFSET_FAIL_RET``
     - 16 B
     - **Failure retry counter.** Tracks persistent
       boot failure count for auto-recovery logic.
     - | ``ralink.h:933``
   * - ``0x0BFFD0``
     - ``OFFSET_FAIL_BOOT_LOG``
     - 16 B
     - **Boot failure log pointer / bitmap.**
       Records up to 100 boot failure events using
       bit-level encoding.
     - | ``ralink.h:934``
   * - ``0x0BFFE0``
     - ``OFFSET_FAIL_DEV_LOG``
     - 16 B
     - **Device failure log pointer / bitmap.**
       Records up to 100 device-level failure events
       using bit-level encoding.
     - | ``ralink.h:935``

6.8 Miscellaneous Board Settings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: Miscellaneous parameter fields
   :header-rows: 1
   :widths: 8,22,6,30,34

   * - Factory Offset
     - C Macro
     - Size
     - Description
     - Source / Notes
   * - ``0x0B018A``
     - ``OFFSET_BOOT_VER``
     - 4 B
     - **Bootloader version record.** Updated when
       the bootloader (U-Boot / ATF) is upgraded.
     - | ``ralink.h:788``
   * - ``0x0BFF30``
     - ``OFFSET_IPADDR_LAN``
     - 16 B
     - **Custom LAN IP address.** Overrides the default
       ``192.168.50.1``. Used in ATE (factory testing)
       environments.
     - | ``ralink.h:937``
   * - ``0x0BFFA0``
     - ``OFFSET_DEV_FLAGS``
     - 16 B
     - **Device-dependent feature flags.** Bitfield
       controlling optional features (e.g., USB mode,
       LED behavior, fan control).
     - | ``ralink.h:931``

--------------------------------------------------------------------------------
7. Group 4: Additional Power / RF Offsets (NOR Flash Legacy)
--------------------------------------------------------------------------------

These offsets are **not used by MT798X** but are listed here for completeness
as they exist in ``ralink.h`` for other Ralink platforms.

.. list-table:: Legacy NOR Flash offsets (non-MT798X)
   :header-rows: 1
   :widths: 12,25,8,55

   * - Flash Offset
     - C Macro
     - Size
     - Description
   * - ``0x40096``
     - ``OFFSET_POWER_5G_TX0_36_x6``
     - ``~0x34``
     - 5 GHz TX0 per-channel power for 36-channel mode (MT7915D)
   * - ``0x400CA``
     - ``OFFSET_POWER_5G_TX1_36_x6``
     - ``~0x34``
     - 5 GHz TX1 per-channel power (MT7915D)
   * - ``0x400FE``
     - ``OFFSET_POWER_5G_TX2_36_x6``
     - ``~0x34``
     - 5 GHz TX2 per-channel power (MT7915D)
   * - ``0x480DE``
     - ``OFFSET_POWER_2G``
     - ``~0x22``
     - 2.4 GHz per-channel power (legacy Ralink)
   * - ``0x401A0``
     - ``OFFSET_TXBF_PARA``
     - variable
     - TX beamforming parameters (defined at ``ralink.h:848``,
       but only used on certain models)
   * - ``0x4FF60``
     - ``OFFSET_FORCE_USB3``
     - 1 B
     - Force USB 3.0 mode flag (``ralink.h:872``)

--------------------------------------------------------------------------------
8. Boot-Time Read Sequence
--------------------------------------------------------------------------------

The RC daemon reads Factory parameters during early init via
:c:func:`init_syspara` (``init-ralink.c``). The read order is:

.. code-block:: text

   init.c: sysinit()
     └── init-ralink.c: init_syspara()
         ├── [Diag] MTDPartitionRead("Factory", buf, 0, 0x1000)   — hexdump
         ├── FRead(HWID)                    0x0BFE00 (4B)
         ├── FRead(HW_VERSION)              0x0BFE04 (8B)
         ├── FRead(HW_BOM)                  0x0BFE0C (32B)
         ├── FRead(HW_DATE_CODE)            0x0BFE3E (8B)
         ├── FRead(MAC_ADDR)                0x00004 (6B)  → base MAC
         ├── FRead(MAC_GMAC0)               0x0002A (6B)  → LAN MAC
         ├── FRead(MAC_GMAC1)               0x00024 (6B)  → WAN MAC
         ├── FRead(TERRITORY_CODE)          0x0BFF90 (5B)
         ├── FRead(SERIAL_NUMBER)           0x0BFFF0 (32B)
         ├── FRead(DEV_FLAGS)               0x0BFFA0 (16B)
         ├── FRead(ODMPID)                  0x0BFFB0 (16B)
         ├── FRead(REG2G_EEPROM_ADDR)       0x0B0234 (10B)
         ├── FRead(REG5G_EEPROM_ADDR)       0x0B023E (10B)
         └── FRead(REGSPEC_ADDR)            0x0B0248 (4B)

WiFi driver initialization (in :c:func:`init_wl`)::

   init-ralink.c: init_wl()
     ├── dd if=/dev/mtdX of=/tmp/e2p bs=655360 count=1   — copy Factory[0:640KB]
     └── MTK driver loads /tmp/e2p
         ├── check EEPROM signature at offset 0x0
         ├── read MAC_ADDR at offset 0x4
         └── parse calibration tables from offset 0x40 onward

.. note::

   ``/tmp/e2p`` is a dump of the first 640 KB of Factory (overkill; only
   the first 4 KB contain actual calibration data on MT7981). The MTK WiFi
   driver accesses MAC and calibration data directly from this file, **not**
   via ASUSWRT ``FRead`` or NVRAM. This is why the ``wl0_hwaddr`` /
   ``wl1_hwaddr`` NVRAM variables have no effect on WiFi MACs — the driver
   reads offset 0x4 from ``/tmp/e2p`` independently.

--------------------------------------------------------------------------------
9. Source File Index
--------------------------------------------------------------------------------

.. list-table:: Key source files
   :header-rows: 1
   :widths: 30,70

   * - File
     - Role
   * - ``release/src/router/shared/sysdeps/ralink/ralink.h``
     - **All ``OFFSET_*`` macro definitions.** The authoritative source for
       every offset listed in this document. MT798X path uses
       ``FTRY_PARM_SHIFT = 0xB0000`` for ASUS parameters.
   * - ``release/src/router/shared/flash_mtd.h``
     - Declares ``FACTORY_MTD_NAME = "Factory"``, ``MTDPartitionRead()``, and
       ``FRead()`` prototypes.
   * - ``release/src/router/shared/flash_mtd.c``
     - Implements ``FRead()`` (L558), ``FactoryRead()`` (L473), and
       ``MTDPartitionRead()`` (L367). ``FRead`` translates the macro
       absolute addresses into MTD partition reads.
   * - ``release/src/router/rc/sysdeps/init-ralink.c``
     - **Boot-time consumer of all Factory offsets.**
       ``init_syspara()`` (L2058) reads board parameters into NVRAM;
       ``init_wl()`` (L1531) prepares ``/tmp/e2p`` for the WiFi driver.
   * - ``release/src/router/rc/init.c``
     - Top-level ``sysinit()`` entry point (L20232) that calls
       ``init_syspara()`` (L20560).
   * - ``release/src/router/shared/sysdeps/qca/qca.h``
     - QCA (Qualcomm) platform ``OFFSET_*`` macros for cross-reference.

--------------------------------------------------------------------------------
10. Sample Binary Data (ZBT-Z8103AX-C)
--------------------------------------------------------------------------------

The following values are extracted from the production Factory backup of a
ZBTlink ZBT-Z8103AX-C device (``backup_Zbtlink_ZBT-Z8103AX-C_mtd_Factory_*
.bin``). **All meaningful data is confined to the first 4 KB** (``0x00000``–
``0x00FFF``); the calibration tables end at approximately ``0x0D80``, with
the remainder of the 4 KB block padded with zeros. The entire area from
``0x01000`` to ``0x1FFFFF`` is ``0xFF`` (NAND erase state), save for a stray
flash write artifact at ``0x08000`` (``78 a3 51 22 33 55``) that is not
functional calibration data.

.. list-table:: Measured data values from reference binary
   :header-rows: 1
   :widths: 10,8,40,42

   * - Factory Offset
     - Size
     - Hex Value
     - Decoded Value
   * - ``0x00000``
     - 2 B
     - ``81 79``
     - Valid EEPROM signature
   * - ``0x00002``
     - 2 B
     - ``00 00``
     - EEPROM version 0
   * - ``0x00004``
     - 6 B
     - ``f8 5e 3c 69 b3 c6``
     - WiFi base MAC: ``F8:5E:3C:69:B3:C6``
   * - ``0x0000A``
     - 6 B
     - ``f8 5e 3c 69 b3 c7``
     - Reserved: ``F8:5E:3C:69:B3:C7`` (base+1)
   * - ``0x00024``
     - 6 B
     - ``f8 5e 3c 69 b3 c9``
     - WAN MAC: ``F8:5E:3C:69:B3:C9``
   * - ``0x0002A``
     - 6 B
     - ``f8 5e 3c 69 b3 c8``
     - LAN MAC: ``F8:5E:3C:69:B3:C8``
   * - ``0x00190``
     - 16 B
     - ``12 5b 48 4c 00 28 00 00 05 d0 00 00 00 00 00 00``
     - Internal block: ``. [ HL . ( ...``
       (may contain board ID ``HL`` string)
   * - ``0x0BFE00``
     - 4 B
     - ``FF FF FF FF``
     - **HwId: BLANK** (not programmed for ASUS)
   * - ``0x0BFF90``
     - 5 B
     - ``FF FF FF FF FF``
     - **Territory: BLANK**
   * - ``0x0BFFF0``
     - 32 B
     - ``FF FF ... FF FF``
     - **Serial Number: BLANK**

.. warning::

   The ZBT-Z8103AX-C is an **OpenWrt-preloaded OEM device**. Its Factory
   binary contains only the MediaTek RF calibration data (first 4 KB).
   The ASUS board parameter block (``0xB0000``–``0xBFFFF``) is entirely
   blank (all ``0xFF``). When porting to ASUSWRT, these fields **must** be
   populated before production — refer to `Factory Image Construction`_
   below.

11. Factory Image Construction
----------------------------------------------------------------------------

When migrating from OEM (OpenWrt) firmware to ASUSWRT, the Factory image must
be extended to include the ASUS board parameter block. A minimal valid image
requires at minimum:

.. code-block:: shell

   # 1. Keep original calibration data (first 4 KB)
   dd if=oem_factory.bin of=factory_full.bin bs=4096 count=1

   # 2. Fill gap from 0x1000 to 0xB0000 with 0xFF (NAND erase state)
   dd if=/dev/zero bs=$((0xB0000 - 0x1000)) count=1 | tr '\000' '\377' >> factory_full.bin

   # 3. Program ASUS parameters (use a script — see example below)
   python3 program_asus_params.py factory_full.bin

   # 4. Pad to 2 MB
   truncate -s $((0x200000)) factory_full.bin

The Python script should write at least: ``HwId`` (0xBFE00, e.g. ``"HL"``),
``HwVer`` (0xBFE04, e.g. ``"1.0"``), ``Territory Code`` (0xBFF90, e.g.
``"CN/01"``), ``Serial Number`` (0xBFFF0), ``REG2G_EEPROM_ADDR`` (0xB0234,
``"0"``), and ``REG5G_EEPROM_ADDR`` (0xB023E, ``"0"``).

--------------------------------------------------------------------------------
12. Revision History
--------------------------------------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15,10,75

   * - Date
     - Author
     - Changes
   * - 2026-07-27
     - Initial
     - First release. Covers all MT798X offsets from ``ralink.h``,
       ZBT-Z8103AX-C binary analysis, and boot-time read sequence.
