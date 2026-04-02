# SolidRun SFP Database

Database of SFP modules tested on SolidRun ARM based products.

## LX2160

| Part Number | Vendor | Description | Notes | Links |
| --- | --- | --- | --- | --- |
| ASF-10G-T | [10Gtek](https://www.10gtek.com/) | 100M/1G/2.5G/5G/10G NBase-T RJ45 Module | | |
| ASA-SFP-RJ45 | AsahiNet | 10/100/1GBase-T RJ45 Module | | |
| AFBR-57R5AEZ | Avago | 1G SFP Fiber Module | | |
| GLC-T | Cisco | 10/100/1GBase-T RJ45 Module | <ul><li>2025-09-29: requires kernel patch, work in progress</li></ul> | <ul><li>[LKML cisco-1g-sfp-phy-features-v1](https://lore.kernel.org/r/20250823-cisco-1g-sfp-phy-features-v1-1-3b3806b89a22@solid-run.com)</li></ul> |
| GLC-TE | Cisco | 10/100/1GBase-T RJ45 Module | <ul><li>2025-09-29: requires kernel patch, work in progress</li></ul> | <ul><li>[LKML cisco-1g-sfp-phy-features-v1](https://lore.kernel.org/r/20250823-cisco-1g-sfp-phy-features-v1-1-3b3806b89a22@solid-run.com)</li></ul> |
| S28-AO02 | [FS Inc.](https://www.fs.com/) | 25G SFP28 Active Optical Cable (2m) | <ul><li>Supported since Linux v6.5</li><li>2023-08-10: Tested on LX2162 Clearfog: Link + Tx/Rx</li></ul> | <ul><li>[Linux Commit db1a6ad](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=db1a6ad77c180efc7242d7204b9a0c72c8a5a1bb)</li></ul> |
| SFP-10G-AO03 | [FS Inc.](https://www.fs.com/) | 10G SFP+ Active Optical Cable (3m) | <ul><li>2025-09-29: Tested on LX2162 Clearfog & LX2160 Clearfog-CX: Link + Tx/Rx</li></ul> | |
| SFP-10GSR-85 | [FS Inc.](https://www.fs.com/) | 10G SFP+ Fiber Module | | |
| SFP-25GSL-85 | [FS Inc.](https://www.fs.com/) | 25G SFP28 Fiber Module | <ul><li>2023-08-10: Tested on LX2162 Clearfog: Link + Tx/Rx</li></ul> | |
| SFP28-25GSR-85 | [FS Inc.](https://www.fs.com/) | 25G SFP28 Fiber Module | <ul><li>2023-08-10: Tested on LX2162 Clearfog: Link + Tx/Rx</li></ul> | |
| 508377 | [IC Intracom Vertriebs GmbH](https://icintracom.de/) | 10G SFP+ Passive Direct Attach Copper Twinax Cable | | |
| SB10ERLCC000L32 | Jabil Photonics | 10G SFP+ Fiber Module | | |
| SF01S1RJC000T | Jabil Photonics | 1G SFP GBase-T RJ45 Module | | |
| L01D-SR | Lambda Gan | 10G SFP+ Fiber Module | | |
| LX1801CNR | Linktel | 10/100/1GBase-T RJ45 Module | | |
| GLC-BX-D20-ST | [Sandstone](https://www.sandstonetechnologies.com/) | 1G SFP Fiber Module | | |
| GLC-BX-U20-ST | [Sandstone](https://www.sandstonetechnologies.com/) | 1G SFP Fiber Module | | |
| GLC-SX-MMD-ST | [Sandstone](https://www.sandstonetechnologies.com/) | 1G SFP Fiber Module | | |
| SFP-10G-BX-U80-ST | [Sandstone](https://www.sandstonetechnologies.com/) | 10G SFP+ Fiber Module | | |
| SFP10G-ZR-ST A02 | [Sandstone](https://www.sandstonetechnologies.com/) | 10G SFP+ Fiber Module | <ul><li>problem with connector, don't plug in all the way</li></ul> | |
| GLC-BX-D20-SO | [Solid Optics](https://www.solid-optics.com/) | 1G SFP Fiber Module | | |
| SFP-10G-BX40U-SO | [Solid Optics](https://www.solid-optics.com/) | 10G SFP+ Fiber Module | | |
| SFP-10G-BX80D-SO | [Solid Optics](https://www.solid-optics.com/) | 10G SFP+ Fiber Module | | |
| SFP-10G-CWDM1490-EZR-SO | [Solid Optics](https://www.solid-optics.com/) | 10G SFP+ Fiber Module | | |
| SFP-10G-ER-SO | [Solid Optics](https://www.solid-optics.com/) | 10G SFP+ Fiber Module | <ul><li>2023-08-10: Tested on LX2162 Clearfog: Link + Tx/Rx</li></ul> | |
| SFP-10G-LR-SO | [Solid Optics](https://www.solid-optics.com/) | 10G SFP+ Fiber Module | | |
| SFP-10G-SR-SO | [Solid Optics](https://www.solid-optics.com/) | 10G SFP+ Fiber Module | | |
| SFP-10G-ZR-SO | [Solid Optics](https://www.solid-optics.com/) | 10G SFP+ Fiber Module | | |
| HXSX-ATRC-1 | [Walsun](https://www.walsun.com/) | 100M/1G/2.5G/5G/10G NBase-T RJ45 Module (Commercial Grade) | <ul><li>Supported since Linux v6.5</li><li>Backported to LS-5.15 BSP</li></ul> | <ul><li>[Linux Commit 5859a99](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=5859a99b52254be356d3cca2e40f7f371ef24b0a)</li><li>[Linux Commit ac2e8e3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=ac2e8e3cfe48439a2403b3d616fb654db313e362)</li></ul> |
| HXSX-ATRI-1 | [Walsun](https://www.walsun.com/) | 100M/1G/2.5G/5G/10G NBase-T RJ45 Module (Industrial Grade) | <ul><li>Supported since Linux v6.5</li><li>Backported to LS-5.15 BSP</li></ul> | <ul><li>[Linux Commit 5859a99](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=5859a99b52254be356d3cca2e40f7f371ef24b0a)</li><li>[Linux Commit ac2e8e3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=ac2e8e3cfe48439a2403b3d616fb654db313e362)</li></ul> |

## CN9130

| Part Number | Vendor | Description | Notes | Links |
| --- | --- | :--- | :--- | :--- |
| AFBR-57R5AEZ | Avago | 1G SFP Fiber Module | | |
| L01D-SR | Lambda Gan | 10G SFP+ Fiber Module | | |
| LX1801CNR | Linktel | 10/100/1GBase-T RJ45 Module | | |
| SP-GB-TX-CNFC | source PHOTONICS | 10/100/1GBase-T RJ45 Module | | |
| HXSX-ATRC-1 | [Walsun](https://www.walsun.com/) | 100M/1G/2.5G/5G/10G NBase-T RJ45 Module (Commercial Grade) | <ul><li>Supported since Linux v6.5</li></ul> | <ul><li>[Linux Commit 5859a99](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=5859a99b52254be356d3cca2e40f7f371ef24b0a)</li><li>[Linux Commit ac2e8e3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=ac2e8e3cfe48439a2403b3d616fb654db313e362)</li></ul> |
| HXSX-ATRI-1 | [Walsun](https://www.walsun.com/) | 100M/1G/2.5G/5G/10G NBase-T RJ45 Module (Industrial Grade) | <ul><li>Supported since Linux v6.5</li></ul> | <ul><li>[Linux Commit 5859a99](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=5859a99b52254be356d3cca2e40f7f371ef24b0a)</li><li>[Linux Commit ac2e8e3](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/.clang-format?h=v6.5&id=ac2e8e3cfe48439a2403b3d616fb654db313e362)</li></ul> |

# A388

| Part Number | Vendor | Description | Notes | Links |
| --- | --- | --- | --- | --- |
| AFBR-57R5AEZ | Avago | 1G SFP Fiber Module | | |
| LX1801CNR | Linktel | 10/100/1GBase-T RJ45 Module | | |
| SP-GB-TX-CNFC | source PHOTONICS | 10/100/1GBase-T RJ45 Module | | |
| TL-SM410U | TP-Link | 2.5GBase-T SFP Module (single speed) | | |

# 8040

| Part Number | Vendor | Description | Notes | Links |
| --- | --- | --- | --- | --- |
| ASF85-24-X2 | [10Gtek](https://www.10gtek.com/) | 1G SFP Fiber Module | | |
| AXS85-192-M3 | [10Gtek](https://www.10gtek.com/) | 10G SFP+ Fiber Module | | |
| CAB-10GSFP-P1M | [10Gtek](https://www.10gtek.com/) | 10G Direct Attach Cable | | |
| FTLX8571D3BCL | Finisar | 10G SFP+ Fiber Module | | |
| LX1801CNR | Linktel | 10/100/1GBase-T RJ45 Module | | |
| WO-SWS-1213-003K | Wave Optics | 1G SFP Fiber Module | | |
| WO-SWS-1215-003K | Wave Optics | 1G SFP Fiber Module | | |
