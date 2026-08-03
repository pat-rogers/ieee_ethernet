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

with Ada.Unchecked_Conversion;
with Interfaces;  use Interfaces;
with System;      use System;

package body IEEE_Ethernet is

   Host_Is_Little_Endian : constant Boolean := System.Default_Bit_Order = System.Low_Order_First;

   -------------
   -- To_Host --
   -------------

   function To_Host (Value : Unsigned_32) return Unsigned_32 is
     (if Host_Is_Little_Endian then
         Shift_Left  (Value and 16#0000_00FF#, 24) or
         Shift_Left  (Value and 16#0000_FF00#, 8)  or
         Shift_Right (Value and 16#00FF_0000#, 8)  or
         Shift_Right (Value, 24)
      else Value);
   --  Network byte order is big-endian, so on a little-endian host the octets
   --  are reversed; on a big-endian host the value is already in host order.

   ------------------
   -- Is_Multicast --
   ------------------

   function Is_Multicast (IP : in IPv4_Address) return Boolean is
     ((IP (IP'First) and 16#F0#) = 16#E0#);
     --  First octet is not less than 224 (the expected range is 224 .. 239)

   -----------------------------------
   -- As_Ethernet_Multicast_Address --
   -----------------------------------

   function As_Ethernet_Multicast_Address (Multicast_IP : IPv4_Address) return Ethernet_Address is
      Result : Ethernet_Address;
   begin
      --  see Wright and Stevens, pp 341, 342
      Result (1) := 16#01#;
      Result (2) := 16#00#;
      Result (3) := 16#5E#;
      Result (4) := Multicast_IP (2) and 16#7F#;
      Result (5) := Multicast_IP (3);
      Result (6) := Multicast_IP (4);
      return Result;
   end As_Ethernet_Multicast_Address;

   -------------------
   -- Is_Link_Local --
   -------------------

   function Is_Link_Local (IP : in IPv4_Address) return Boolean is
     (((IP (1) and 16#FF#) = 16#A9#) and
      ((IP (2) and 16#FF#) = 16#FE#));

   --------------
   -- Is_Valid --
   --------------

   function Is_Valid (This : Subnet_Mask) return Boolean is
      --  The subnet_mask value must consist of contiguous binary ones followed
      --  exclusively by contiguous binary zeros

      function As_Unsigned_32 is new Ada.Unchecked_Conversion
        (Source => Subnet_Mask, Target => Unsigned_32);

      Test_Bit : Unsigned_32 := Shift_Left (Value => 1, Amount => 31);
      Arg_Bits : constant Unsigned_32 := To_Host (As_Unsigned_32 (This));
   begin
      --  find first zero bit
      while Test_Bit /= 0 loop
         exit when (Test_Bit and Arg_Bits) = 0;
         Test_Bit := Shift_Right (Test_Bit, 1);
      end loop;
      --  make sure no non-zero bit follows first zero bit
      while Test_Bit /= 0 loop
         if (Test_Bit and Arg_Bits) /= 0 then
            return False;
         end if;
         Test_Bit := Shift_Right (Test_Bit, 1);
      end loop;
      return True;
   end Is_Valid;

end IEEE_Ethernet;
