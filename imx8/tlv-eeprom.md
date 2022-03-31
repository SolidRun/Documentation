# iMX8M EEPROM Programming

Starting from April 01. 2022, the EEPROMs on Carriers, i.MX8M Plus SoMs and COM-Express Modules are being programmed with identifying information such as the product name and SKUs to allow for programmatic identification of hardware. The data is is structured according to the [ONIE TLV Standard](https://opencomputeproject.github.io/onie/design-spec/hw_requirements.html#board-eeprom-information-format).

## Carrier

The EEPROM on Clearfog Base and Pro on i2c-3 at 0x57 is programmed with the following TLV entries:

- TLV_CODE_PRODUCT_NAME (mandatory)
  Human-readable name of the Product.
- TLV_CODE_PART_NUMBER (mandatory)
  Identifying part number from ordering system (SKU) without BOM suffix (/0).
- TLV_CODE_SERIAL_NUMBER (mandatory)
- TLV_CODE_MANUF_DATE (mandatory)
  Manufacturing Date (MM/DD/YYYY HH:MM:SS)
- TLV_CODE_DEVICE_VERSION (mandatory)
  Board Revision, incremented when parts or layout changes;
  MAJOR.MINOR revisions are encoded by storing MAJOR in the four most significant bits, MINOR in the four least significant bits.
- TLV_CODE_MANUF_NAME (mandatory)
- TLV_CODE_MANUF_COUNTRY (mandatory)
- TLV_CODE_VENDOR_NAME (mandatory)
  Name of Vendor, typically SolidRun.
- TLV_CODE_VENDOR_EXT (optional):
  This is a custom entry using the following structure:
  1. 4 byte IANA enterprise number in network byte order (we use 0xFFFFFFFF for now)
  2. 1 byte solidrun tlv code
    - SR_TLV_CODE_KIT_NUMBER (0x10): Identifying part number (SKU) when sold as a Kit.
  3. up to 250 byte of binary data

### Example

- TLV_CODE_PRODUCT_NAME: HummingBoard Ripple
- TLV_CODE_PART_NUMBER: SRHBCRE000CV25
- TLV_CODE_SERIAL_NUMBER: NG01829212000006
- TLV_CODE_MANUF_DATE: 12/24/2022 07:35:59
- TLV_CODE_DEVICE_VERSION: 0x25 (2.5)
- TLV_CODE_MANUF_NAME: IMI
- TLV_CODE_MANUF_COUNTRY: PH
- TLV_CODE_VENDOR_NAME: SolidRun
- TLV_CODE_VENDOR_EXT: 0xFFFFFFFF 0x10 SRMP8QDW00D01GE008R02CH

### Programming from U-Boot

The EEPROM can be programmed from the U-Boot cli accordingly by the following commands:

```
tlv_eeprom_dev 1
tlv_eeprom erase
tlv_eeprom set 0x21 'HummingBoard Ripple'
tlv_eeprom set 0x22 'SRHBCRE000CV25'
tlv_eeprom set 0x23 'NG01829212000006'
tlv_eeprom set 0x25 '12/24/2022 07:35:59'
tlv_eeprom set 0x26 '0x25'
tlv_eeprom set 0x2b 'IMI'
tlv_eeprom set 0x2c 'PH'
tlv_eeprom set 0x2d 'SolidRun'
tlv_eeprom set 0xfd '0xff 0xff 0xff 0xff 0x10 0x53 0x52 0x4d 0x50 0x38 0x51 0x44 0x57 0x30 0x30 0x44 0x30 0x31 0x47 0x45 0x30 0x30 0x38 0x52 0x30 0x32 0x43 0x48'
tlv_eeprom write
```

## SoM

The EEPROM on i.MX8M Plus SoMs on i2c-1 at 0x50 is programmed with the following TLV entries:

- TLV_CODE_PRODUCT_NAME (mandatory)
  Human-readable name of the Product.
- TLV_CODE_PART_NUMBER (mandatory)
  Identifying part number from ordering system (long SKU) without BOM suffix (/0).
- TLV_CODE_SERIAL_NUMBER (mandatory)
- TLV_CODE_MAC_BASE (optional)
  First MAC Address for the on-COM (SoC) network interface(s)
- TLV_CODE_MANUF_DATE (mandatory)
  Manufacturing Date (MM/DD/YYYY HH:MM:SS)
- TLV_CODE_DEVICE_VERSION (mandatory)
  Board Revision, incremented when parts or layout changes;
  MAJOR.MINOR revisions are encoded by storing MAJOR in the four most significant bits, MINOR in the four least significant bits.
- TLV_CODE_PLATFORM_NAME
  Family name for the SoC.
- TLV_CODE_MAC_SIZE (optional)
  Number of consecutive MAC Addresses starting from TLV_CODE_MAC_BASE. Usually 1.
- TLV_CODE_MANUF_NAME (mandatory)
- TLV_CODE_MANUF_COUNTRY (mandatory)
- TLV_CODE_VENDOR_NAME (mandatory)
  Name of Vendor, typically SolidRun.
- TLV_CODE_VENDOR_EXT (optional):
  This is a custom entry using the following structure:
  1. 4 byte IANA enterprise number in network byte order (we use 0xFFFFFFFF for now)
  2. 1 byte solidrun tlv code
    - SR_TLV_CODE_KIT_NUMBER (0x10): Identifying part number (SKU) when sold as a Kit.
  3. up to 250 byte of binary data


### Example

- TLV_CODE_PRODUCT_NAME: i.MX8M Plus System on Module
- TLV_CODE_PART_NUMBER: S8DN18C11/1
- TLV_CODE_SERIAL_NUMBER: NG01865214200061
- TLV_CODE_MANUF_DATE: 12/24/2022 07:35:59
- TLV_CODE_DEVICE_VERSION: 0x11 (1.1)
- TLV_CODE_PLATFORM_NAME: i.MX8M Plus
- TLV_CODE_MANUF_NAME: Nistec
- TLV_CODE_MANUF_COUNTRY: IL
- TLV_CODE_VENDOR_NAME: SolidRun
- TLV_CODE_VENDOR_EXT: 0xFFFFFFFF 0x10 SRMP8QDW00D01GE008X01CE

### Programming from U-Boot

The EEPROM can be programmed from the U-Boot cli accordingly by the following commands:

```
tlv_eeprom_dev 0
tlv_eeprom erase
tlv_eeprom set 0x21 'i.MX8M Plus System on Module'
tlv_eeprom set 0x22 'SRMP8QDW00D01GE008V12C0'
tlv_eeprom set 0x23 'NG01873214300067'
tlv_eeprom set 0x25 '12/24/2022 07:35:59'
tlv_eeprom set 0x26 '0x12'
tlv_eeprom set 0x28 'i.MX8M Plus'
tlv_eeprom set 0x2b 'Nistec'
tlv_eeprom set 0x2c 'IL'
tlv_eeprom set 0x2d 'SolidRun'
tlv_eeprom set 0x24 '12:34:56:78:9a:bc'
tlv_eeprom set 0x2a '1'
tlv_eeprom set 0xfd '0xff 0xff 0xff 0xff 0x10 0x53 0x52 0x4d 0x50 0x38 0x51 0x44 0x57 0x30 0x30 0x44 0x30 0x31 0x47 0x45 0x30 0x30 0x38 0x55 0x30 0x32 0x43 0x48' # HBp
tlv_eeprom set 0xfd '0xff 0xff 0xff 0xff 0x10 0x53 0x52 0x4d 0x50 0x38 0x51 0x44 0x57 0x30 0x30 0x44 0x30 0x31 0x47 0x45 0x30 0x30 0x38 0x58 0x30 0x30 0x43 0x45' # CBp
tlv_eeprom write
```
