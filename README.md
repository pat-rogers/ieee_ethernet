# ieee_ethernet

IEEE 802.3 Ethernet declarations in Ada, together with the Serial Management Interface (SMI) and PHY transceiver abstractions.

The crate is architecture-independent: it sets neither `Target` nor `Runtime` in its project file, taking both from whatever client project imports it. It is never a main project.

## Contents

- **`IEEE_Ethernet`**: root package (`pragma Pure`). MTU and frame-length constants and types, `Octet`, `IPv4_Address`, `Subnet_Mask`, `Ethernet_Address`, multicast/link-local queries, IPv4 to Ethernet multicast address mapping.
- **`IEEE_Ethernet.MAC_Media_Signals`**: the two MAC-to-PHY media interfaces, MII and RMII, and the number of signals comprising each (`pragma Pure`). A target maps those signals to the pins carrying them.
- **`IEEE_Ethernet.SMI`**: the two-wire management interface of IEEE 802.3 clause 22, also known as MDIO. PHY addresses, register indexes, the Basic Register Set indexes, and representation clauses for the Basic Control and Basic Status registers.
- **`IEEE_Ethernet.SMI.IO`**: abstract `SMI_IO_Driver` tagged type: `Read_SMI_Register` / `Write_SMI_Register`, overridden by an MCU-family-specific concrete type. Concrete class-wide `Get_BCR` / `Put_BCR` / `Get_BSR` dispatch to those.
- **`IEEE_Ethernet.PHY`**: abstract `PHY_Transceiver` tagged type. A handful of primitives are abstract (`Initialize`, `Get_Operating_Mode`, `PHY_Device_Address`, `Requires_RMII`); the rest are concrete and class-wide, since clause 22.2.4.1 standardizes the behavior: auto-negotiation control and queries, loopback, power down/up, reset, link state, and `Negotiate_Speed_And_Duplex_Mode`.

## Building

An Alire crate:

```
alr build
```

`ieee_ethernet.gpr` honors `IEEE_Ethernet_Build_Mode` (`release`, `validation`, or `development`) and applies `gnat.adc` as global configuration pragmas; that file leaves preconditions checked and postconditions ignored.

There are no crate dependencies: the sources use only `Ada.Real_Time`, `Ada.Unchecked_Conversion`, `Interfaces`, and `System`.

## Tests

`test/host/` holds a host-native harness for the root package, which is target-independent and so runs on the development machine unchanged. Only the closure of the main is built, so the SMI and PHY units are not compiled there.

## License

Apache License 2.0 with the LLVM exception, the SPDX expression `Apache-2.0 WITH LLVM-exception`. See [LICENSE](LICENSE).

Copyright (C) 2026 Patrick Rogers (progers@classwide.com)
