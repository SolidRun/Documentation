# CN913x EEPROM Programming

Starting from April 01. 2022, the EEPROMs on Carriers, SoMs and COM-Express Modules are being programmed with identifying information such as the product name and SKUs to allow for programmatic identification of hardware. The data is is structured according to the [ONIE TLV Standard](https://opencomputeproject.github.io/onie/design-spec/hw_requirements.html#board-eeprom-information-format).

## Carrier

The EEPROM on Clearfog Base and Pro on i2c-0 at 0x52 is programmed with the following TLV entries:

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

### Example

- TLV_CODE_PRODUCT_NAME: Clearfog Base
- TLV_CODE_PART_NUMBER: SRCFCB9130IV14
- TLV_CODE_SERIAL_NUMBER: NG01725204200060
- TLV_CODE_MANUF_DATE: 12/24/2022 07:35:59
- TLV_CODE_DEVICE_VERSION: 0x14 (1.4)
- TLV_CODE_MANUF_NAME: IMI
- TLV_CODE_MANUF_COUNTRY: PH
- TLV_CODE_VENDOR_NAME: SolidRun

### Programming from U-Boot

The EEPROM can be programmed from the U-Boot cli accordingly by the following commands:

```
tlv_eeprom dev 0
tlv_eeprom erase
tlv_eeprom set 0x21 'Clearfog Base'
tlv_eeprom set 0x22 'SRCFCB9130IV14'
tlv_eeprom set 0x23 'NG01725204200060'
tlv_eeprom set 0x25 '12/24/2022 07:35:59'
tlv_eeprom set 0x26 '0x14'
tlv_eeprom set 0x2b 'IMI'
tlv_eeprom set 0x2c 'PH'
tlv_eeprom set 0x2d 'SolidRun'
tlv_eeprom write
```

## COM Express

The EEPROM on CN913x CEX-7 Modules on i2c-0 at 0x50 is programmed with the following TLV entries:

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

### Example

- TLV_CODE_PRODUCT_NAME: CN9132 COM Express 7 Module
- TLV_CODE_PART_NUMBER: SRC9132S64D00GE008V12
- TLV_CODE_SERIAL_NUMBER: NG01848213000015
- TLV_CODE_MANUF_DATE: 12/24/2022 07:35:59
- TLV_CODE_DEVICE_VERSION: 0x12 (1.2)
- TLV_CODE_MANUF_NAME: Nistec
- TLV_CODE_MANUF_COUNTRY: IL
- TLV_CODE_VENDOR_NAME: SolidRun

### Programming from U-Boot

The EEPROM can be programmed from the U-Boot cli accordingly by the following commands:

```
tlv_eeprom dev 0
tlv_eeprom erase
tlv_eeprom set 0x21 'CN9132 COM Express 7 Module'
tlv_eeprom set 0x22 'SRC9132S64D00GE008V12'
tlv_eeprom set 0x23 'NG01848213000015'
tlv_eeprom set 0x25 '12/24/2022 07:35:59'
tlv_eeprom set 0x26 '0x12'
tlv_eeprom set 0x2b 'IMI'
tlv_eeprom set 0x2c 'PH'
tlv_eeprom set 0x2d 'SolidRun'
tlv_eeprom write
```

## SoM

The EEPROM on CN913x SoMs on i2c-0 at 0x53 is programmed with the following TLV entries:

- TLV_CODE_PRODUCT_NAME (mandatory)
  Human-readable name of the Product.
- TLV_CODE_PART_NUMBER (mandatory)
  Identifying part number from ordering system (long SKU) without BOM suffix (/0).
- TLV_CODE_SERIAL_NUMBER (mandatory)
- TLV_CODE_MANUF_DATE (mandatory)
  Manufacturing Date (MM/DD/YYYY HH:MM:SS)
- TLV_CODE_DEVICE_VERSION (mandatory)
  Board Revision, incremented when parts or layout changes;
  MAJOR.MINOR revisions are encoded by storing MAJOR in the four most significant bits, MINOR in the four least significant bits.
- TLV_CODE_PLATFORM_NAME
  Family name for the SoC.
- TLV_CODE_MANUF_NAME (mandatory)
- TLV_CODE_MANUF_COUNTRY (mandatory)
- TLV_CODE_VENDOR_NAME (mandatory)
  Name of Vendor, typically SolidRun.

### Example

- TLV_CODE_PRODUCT_NAME: CN9130 System on Module
- TLV_CODE_PART_NUMBER: SRS9130S64D04GE008V11C0
- TLV_CODE_SERIAL_NUMBER: NG01862214200020
- TLV_CODE_MANUF_DATE: 12/24/2022 07:35:59
- TLV_CODE_DEVICE_VERSION: 0x11 (1.1)
- TLV_CODE_PLATFORM_NAME: Octeon TX2
- TLV_CODE_MANUF_NAME: Nistec
- TLV_CODE_MANUF_COUNTRY: IL
- TLV_CODE_VENDOR_NAME: SolidRun

### Programming from U-Boot

The EEPROM can be programmed from the U-Boot cli accordingly by the following commands:

```
tlv_eeprom dev 1
tlv_eeprom erase
tlv_eeprom set 0x21 'CN9130 System on Module'
tlv_eeprom set 0x22 'SRS9130S64D04GE008V11C0'
tlv_eeprom set 0x23 'NG01862214200020'
tlv_eeprom set 0x25 '12/24/2022 07:35:59'
tlv_eeprom set 0x26 '0x11'
tlv_eeprom set 0x28 'Octeon TX2'
tlv_eeprom set 0x2b 'Nistec'
tlv_eeprom set 0x2c 'IL'
tlv_eeprom set 0x2d 'SolidRun'
tlv_eeprom write
```
