# IEEE_Ethernet

This crate provides fundamental, common types and interfaces for other crates that define an IPv4 Ethernet stack, especially OSI Layer 1 and Layer 2 implementations, but also OSI layers above those two. 

The subsystem represents IEEE 802.3 Ethernet standard concepts and interfaces. The subsystem root package defines basic standard types. Dedicated child packages provide:

- types and constants for the Serial Management Interface (SMI), 

- an abstract SMI I/O driver type, 

- an abstract PHY transceiver type using the SMI I/O type for communication, and

- basic declarations for the MAC-PHY communication media interfaces.

The crate is architecture-independent: it sets neither `Target` nor `Runtime` in its project file, taking both from whatever client project imports it. It is never a main project.

## Contents

Package `IEEE_Ethernet` is the subsystem root, declaring fundamental types for an IPv4 network stack: `IPv4_Address`, `Subnet_Mask`, `Ethernet_Address`, multicast/link-local queries, MTU and frame-length constants and types, and so on.

Package `IEEE_Ethernet.SMI`provides the fundamental types and constants for the two-wire management interface of IEEE 802.3 clause 22, also known as MDIO.  (MDIO is also one of the signal names, so we use the more distinguishable standard SMI term). Major types include PHY addresses, the Basic Register Set indexes, and types representing the IEEE-standard Basic Control Register (BCR) and Basic Status Register (BSR).

Package `IEEE_Ethernet.SMI.IO` defines an abstract `SMI_IO_Driver` type with abstract procedures  `Read_SMI_Register` and `Write_SMI_Register`. These abstract procedure are to be overridden by an MCU-family-specific concrete type. Concrete class-wide operations are also provided for convenience: `Get_BCR` / `Put_BCR` / `Get_BSR`, all three of which dynamically dispatch to the two abstract procedures.

Package `IEEE_Ethernet.PHY`defines an abstract `PHY_Transceiver` type. Concrete instances of the abstract type are used to declare actual PHY devices. For example, a specific instance of the `LAN8742a` PHY transceiver in a dedicated crate is defined as an extension of the PHY transceiver type declared in this crate. 

Some of the PHY transceiver type's primitives are abstract (`Initialize`, `Get_Operating_Mode`, `PHY_Device_Address`, `Requires_RMII`) because they are hardware-specific. The remaining  primitives are concrete and class-wide, because clause 22.2.4.1 standardizes the behavior using the BCR and BSR, including auto-negotiation control and queries, loopback, power down/up, reset, link state, and so on. 

The PHY transceiver type is declared as an abstract type, rather than an interface type, for the sake of these concrete primitive operations. In addition, as an abstract type it can contain a component, in this case a component designating any instance of the `SMI_IO_Driver` type. Any concrete PHY driver instance is specific to a given PHY hardware device, but these devices are independent of the target boards that have them installed. The target boards define how a PHY device can be communicated with on tose boards.  Therefore, the PHY driver uses this SMI driver component to communicate with the PHY in the hardware-specific manner defined by the target board.

Lastly, package `IEEE_Ethernet.Media` declares the two MAC-to-PHY media interface names, i.e., MII and RMII, and the number of signals comprising each. Crates representing target boards use those fundamental types to map MII or RMII signals to the GPIO pins carrying them on each physical target board, because that is where those pin assignments are defined. 

## Building

An Alire crate:

```
alr build
```

`ieee_ethernet.gpr` honors `IEEE_Ethernet_Build_Mode` (`release`, `validation`, or `development`) and applies `gnat.adc` as a global configuration pragmas file. That file sets preconditions to be checked and postconditions to be ignored.

There are no crate dependencies: the sources use only `Ada.Real_Time`, `Ada.Unchecked_Conversion`, `Interfaces`, and `System`.

## Tests

`test/host/` holds a partial host-native harness for the root package functions, including address query functions and the subnet mask validity check function. These functions are target-independent so the test runs on the development machine. Only the closure of the main is built, so the SMI and PHY units are not compiled there.

## License

Apache License 2.0 with the LLVM exception, the SPDX expression `Apache-2.0 WITH LLVM-exception`. See [LICENSE](LICENSE).

Copyright (C) 2026 Patrick Rogers (progers@classwide.com)
