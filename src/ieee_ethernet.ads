-----------------------------------------------------------------------
--  ieee_ethernet - IEEE 802.3 Root Package
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

--  This rather grandiosely named package is the root for the IEEE_Ethernet
--  subsystem, a set of packages representing IEEE 802.3 standard functionality.

package IEEE_Ethernet is

   pragma Pure;

   Max_Transmission_Unit : constant := 1500;

   Ether_Header_Length : constant := 14;

   FCS_Length : constant := 4;
   --  Ethernet frame check sequence (CRC-32) trailer.

   Ethernet_II_Frame_Length_Limit : constant := Max_Transmission_Unit + Ether_Header_Length + FCS_Length;
   --  Largest Ethernet II frame a memory buffer must hold: the IPv4 MTU, the
   --  14-byte Ethernet header, and the 4-byte FCS. The FCS is present in the
   --  buffer only when the MAC is not configured to strip (Rx) or append (Tx)
   --  it.

   type Ethernet_II_Frame_Length is range 0 .. Ethernet_II_Frame_Length_Limit;
   --  Size of a complete Ethernet II frame carried in a memory buffer.

   type MTU_Length is range 0 .. Max_Transmission_Unit;
   --  Upper bound on the L3 payload (e.g., IPv4 datagram) an interface will carry.

   type Octet is mod 2 ** 8;

   type IPv4_Address is array (1 .. 4) of Octet with Component_Size => 8;

   IP_Unspecified_Address : constant IPv4_Address := (others => 0);
   IP_Broadcast_Address   : constant IPv4_Address := (others => 16#FF#);

   All_Systems : constant IPv4_Address := (224, 0, 0, 1);
   All_Routers : constant IPv4_Address := (224, 0, 0, 2);

   type Subnet_Mask is array (IPv4_Address'Range) of Octet with Component_Size => 8;

   Subnet_Zero         : constant Subnet_Mask := (others => 0);
   Default_Subnet_Mask : constant Subnet_Mask := (255, 255, 255, 0); -- AKA "/24"

   function Is_Valid (This : Subnet_Mask) return Boolean;

   type Ethernet_Address is array (1 .. 6) of Octet with Component_Size => 8;
   --  ie, MAC Address, Hardware Address

   Ethernet_Invalid_Address   : constant Ethernet_Address := (others => 0);
   Ethernet_Broadcast_Address : constant Ethernet_Address := (others => 16#FF#);

   function Is_Multicast (IP : in IPv4_Address) return Boolean with Inline;

   function Is_Link_Local (IP : in IPv4_Address) return Boolean;

   function As_Ethernet_Multicast_Address (Multicast_IP : IPv4_Address) return Ethernet_Address
     with Inline;
   --  Converts this multicast IP address to an Ethernet hardware address

   type Organization_Unique_Id is array (1 .. 3) of Octet with Component_Size => Octet'Size;

end IEEE_Ethernet;
