-----------------------------------------------------------------------
--  ieee_ethernet-smi - IEEE Serial Management Interface
--  Copyright (C) 2026 Patrick Rogers
--  Written by Patrick Rogers (progers@classwide.com)
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

--  This package provides the Serial Management Interface (SMI), the two-wire
--  serial interface defined in IEEE 802.3 to allow a MAC to manage PHY chips.
--  Also known as MDIO (but MDIO is also the name of one of the two lines, so
--  we use SMI in the package name).

with System;

package IEEE_Ethernet.SMI is

   type PHY_Address is mod 2 ** 5;
   --  Per section 22.2.4.5.5 PHYAD (PHY Address) of IEEE 802.3:
   --  The PHY Address is five bits, allowing 32 unique PHY addresses.

   Default_PHY_Address : constant PHY_Address := 0;
   --  Per section 22.2.4.5.5 PHYAD (PHY Address) of IEEE 802.3: A PHY that is
   --  connected to the station management entity via the mechanical interface
   --  defined in 22.6 shall always respond to transactions addressed to PHY
   --  Address zero. A station management entity that is attached to multiple
   --  PHYs must have prior knowledge of the appropriate PHY Address for each
   --  PHY.

   Max_PHY_Address : constant PHY_Address := 31;

   type Register_Index is mod 2 ** 5;
   --  Per IEEE 802.3 Ethernet Standard Clause 22 (Standard SMI) a register
   --  index is five bits, allowing 32 unique registers.

   --  Per the SMI standard, the Basic Register Set registers are implemented by
   --  all compliant PHY devices, and are always at the register indexes given
   --  below. The registers are always 16-bits. Additional Extended registers
   --  are also defined by the standard, and vendors can add their own beyond
   --  those.

   --  Basic Register Set
   SMI_BCR     : constant Register_Index := 0;   -- Basic Control Register
   SMI_BSR     : constant Register_Index := 1;   -- Basic Status Register
   --  Extended Register Set
   SMI_PHYI1R  : constant Register_Index := 2;   -- PHY Id part 1 Register
   SMI_PHYI2R  : constant Register_Index := 3;   -- PHY Id part 2 Register
   SMI_ANAR    : constant Register_Index := 4;   -- Auto-Negotiation Advertisement Register
   SMI_ANLPAR  : constant Register_Index := 5;   -- Auto-Negotiation Link Partner Register
   SMI_ANER    : constant Register_Index := 6;   -- Auto-Negotiation Expansion Register
   SMI_ANNPTR  : constant Register_Index := 7;   -- Auto-Negotiation Next Page Tx Register
   SMI_ANNPRR  : constant Register_Index := 8;   -- Auto-Negotiation Next Page Rx Register
   SMI_MSCR    : constant Register_Index := 9;   -- Master-Slave Control Register
   SMI_MSSR    : constant Register_Index := 10;  -- Master-Slave Status Register
   SMI_PSEC    : constant Register_Index := 11;  -- PSE Control Register
   SMI_PSES    : constant Register_Index := 12;  -- PSE Status Register
   SMI_MMDACR  : constant Register_Index := 13;  -- MMD Access Control Register
   SMI_MMDAADR : constant Register_Index := 14;  -- MMD Access Address/Data Register
   --  Register index 15 is the Extended Status register, defined by IEEE 802.3
   --  only for PHYs that provide a GMII (gigabit); it is unused on the 10/100
   --  PHYs this package targets.

   --  The BCR and BSR register types.

   type Loopback_Modes is (Normal, Loopback) with Size => 1;

   type Speed_Selections is (Low_10Mbps, High_100Mbps) with Size => 1;

   type General_Power_Down_Modes is (Normal_Operation, Power_Down) with Size => 1;

   type Duplex_Modes is (Half_Duplex, Full_Duplex) with Size => 1;

   type Reserved_8_Bits is mod 2 ** 8;

   type Basic_Control_Register is record
      Soft_Reset               : Boolean;
      Loopback_Mode            : Loopback_Modes := Normal;
      Speed_Select             : Speed_Selections := Low_10Mbps;
      --  speed selection is ignored if Auto_Negotiation_Enable is set
      Auto_Negotiation_Enable  : Boolean := False;
      Power_Down_Mode          : General_Power_Down_Modes := Normal_Operation;
      Isolate                  : Boolean := False;     --  Isolate PHY from MII
      Restart_Auto_Negotiation : Boolean := False;
      Duplex_Select            : Duplex_Modes := Half_Duplex;
      --  duplex selection is ignored if Auto_Negotiation_Enable is set
      Reserved_0_7             : Reserved_8_Bits := 0;
   end record with
     Volatile,
     Size => 16;

   for Basic_Control_Register use record
      Soft_Reset               at 0 range 15 .. 15;
      Loopback_Mode            at 0 range 14 .. 14;
      Speed_Select             at 0 range 13 .. 13;
      Auto_Negotiation_Enable  at 0 range 12 .. 12;
      Power_Down_Mode          at 0 range 11 .. 11;
      Isolate                  at 0 range 10 .. 10;
      Restart_Auto_Negotiation at 0 range  9 .. 9;
      Duplex_Select            at 0 range  8 .. 8;
      Reserved_0_7             at 0 range  0 .. 7;
   end record;

   for Basic_Control_Register'Bit_Order use System.Low_Order_First;
   for Basic_Control_Register'Scalar_Storage_Order use System.Low_Order_First;

   type Reserved_2_Bits is mod 2 ** 2;

   type Basic_Status_Register is record
      Supports_100Base_T4             : Boolean;
      Supports_100Base_Tx_Full_Duplex : Boolean;
      Supports_100Base_Tx_Half_Duplex : Boolean;
      Supports_10Base_T_Full_Duplex   : Boolean;
      Supports_10Base_T_Half_Duplex   : Boolean;
      Supports_100Base_T2_Full_Duplex : Boolean;
      Supports_100Base_T2_Half_Duplex : Boolean;
      Extended_Status_Available       : Boolean;
      Reserved_6_7                    : Reserved_2_Bits;
      Auto_Negotiation_Complete       : Boolean;
      Remote_Fault_Detected           : Boolean;
      Supports_Auto_Negotiation       : Boolean;
      Link_Is_Up                      : Boolean;
      Jabber_Condition_Detected       : Boolean;
      Supports_Extended_Capabilities  : Boolean;
   end record with
     Volatile,
     Size => 16;

   for Basic_Status_Register use record
      Supports_100Base_T4             at 0 range 15 .. 15;
      Supports_100Base_Tx_Full_Duplex at 0 range 14 .. 14;
      Supports_100Base_Tx_Half_Duplex at 0 range 13 .. 13;
      Supports_10Base_T_Full_Duplex   at 0 range 12 .. 12;
      Supports_10Base_T_Half_Duplex   at 0 range 11 .. 11;
      Supports_100Base_T2_Full_Duplex at 0 range 10 .. 10;
      Supports_100Base_T2_Half_Duplex at 0 range  9 .. 9;
      Extended_Status_Available       at 0 range  8 .. 8;
      Reserved_6_7                    at 0 range  6 .. 7;
      Auto_Negotiation_Complete       at 0 range  5 .. 5;
      Remote_Fault_Detected           at 0 range  4 .. 4;
      Supports_Auto_Negotiation       at 0 range  3 .. 3;
      Link_Is_Up                      at 0 range  2 .. 2;
      Jabber_Condition_Detected       at 0 range  1 .. 1;
      Supports_Extended_Capabilities  at 0 range  0 .. 0;
   end record;

   for Basic_Status_Register'Bit_Order use System.Low_Order_First;
   for Basic_Status_Register'Scalar_Storage_Order use System.Low_Order_First;

end IEEE_Ethernet.SMI;
