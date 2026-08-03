-----------------------------------------------------------------------
--  test_ieee_ethernet - host-native tests for IEEE_Ethernet
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

--  This test harness exercises the visible functions of IEEE_Ethernet on the
--  development host. Each case states the expected result explicitly so that a
--  failure names the input, the expectation, and what was actually computed.

with Ada.Strings.Fixed;
with Ada.Text_IO;      use Ada.Text_IO;

with IEEE_Ethernet;    use IEEE_Ethernet;

procedure Test_IEEE_Ethernet is

   Cases_Run    : Natural := 0;
   Cases_Failed : Natural := 0;

   -----------
   -- Image --
   -----------

   function Image (Value : Octet) return String is
     (Ada.Strings.Fixed.Trim (Octet'Image (Value), Ada.Strings.Left));

   -----------
   -- Image --
   -----------

   function Image (IP : IPv4_Address) return String is
     (Image (IP (1)) & '.' & Image (IP (2)) & '.' & Image (IP (3)) & '.' & Image (IP (4)));

   -----------
   -- Image --
   -----------

   function Image (Mask : Subnet_Mask) return String is
     (Image (Mask (1)) & '.' & Image (Mask (2)) & '.' & Image (Mask (3)) & '.' & Image (Mask (4)));

   -----------
   -- Image --
   -----------

   function Image (MAC : Ethernet_Address) return String is
      Result : String (1 .. 17);
      Digits_Of : constant String := "0123456789ABCDEF";
      Next      : Positive := Result'First;
   begin
      for K in MAC'Range loop
         Result (Next)     := Digits_Of (Natural (MAC (K) / 16) + 1);
         Result (Next + 1) := Digits_Of (Natural (MAC (K) mod 16) + 1);
         if K /= MAC'Last then
            Result (Next + 2) := ':';
         end if;
         Next := Next + 3;
      end loop;
      return Result;
   end Image;

   -----------
   -- Check --
   -----------

   procedure Check (Description : String; Actual, Expected : Boolean) is
   begin
      Cases_Run := Cases_Run + 1;
      if Actual /= Expected then
         Cases_Failed := Cases_Failed + 1;
         Put_Line ("FAIL: " & Description &
                   " -- expected " & Boolean'Image (Expected) &
                   ", got " & Boolean'Image (Actual));
      end if;
   end Check;

   -----------
   -- Check --
   -----------

   procedure Check (Description : String; Actual, Expected : Ethernet_Address) is
   begin
      Cases_Run := Cases_Run + 1;
      if Actual /= Expected then
         Cases_Failed := Cases_Failed + 1;
         Put_Line ("FAIL: " & Description &
                   " -- expected " & Image (Expected) &
                   ", got " & Image (Actual));
      end if;
   end Check;

   ---------------------------
   -- Check_Multicast_State --
   ---------------------------

   procedure Check_Multicast_State (IP : IPv4_Address; Expected : Boolean) is
   begin
      Check ("Is_Multicast (" & Image (IP) & ')', Is_Multicast (IP), Expected);
   end Check_Multicast_State;

   ----------------------------
   -- Check_Link_Local_State --
   ----------------------------

   procedure Check_Link_Local_State (IP : IPv4_Address; Expected : Boolean) is
   begin
      Check ("Is_Link_Local (" & Image (IP) & ')', Is_Link_Local (IP), Expected);
   end Check_Link_Local_State;

   -------------------------
   -- Check_Mask_Validity --
   -------------------------

   procedure Check_Mask_Validity (Mask : Subnet_Mask; Expected : Boolean) is
   begin
      Check ("Is_Valid (" & Image (Mask) & ')', Is_Valid (Mask), Expected);
   end Check_Mask_Validity;

   -----------------------------
   -- Check_Multicast_Mapping --
   -----------------------------

   procedure Check_Multicast_Mapping (IP : IPv4_Address; Expected : Ethernet_Address) is
   begin
      Check ("As_Ethernet_Multicast_Address (" & Image (IP) & ')',
             As_Ethernet_Multicast_Address (IP), Expected);
   end Check_Multicast_Mapping;

   ------------------------
   -- Test_Mask_Validity --
   ------------------------

   procedure Test_Mask_Validity is
   begin
      --  contiguous ones followed by contiguous zeros
      Check_Mask_Validity (Subnet_Zero,          Expected => True);
      Check_Mask_Validity (Default_Subnet_Mask,  Expected => True);
      Check_Mask_Validity ((128, 0, 0, 0),       Expected => True);
      Check_Mask_Validity ((255, 0, 0, 0),       Expected => True);
      Check_Mask_Validity ((255, 255, 0, 0),     Expected => True);
      Check_Mask_Validity ((255, 255, 254, 0),   Expected => True);   -- /23
      Check_Mask_Validity ((255, 255, 255, 252), Expected => True);  -- /30
      Check_Mask_Validity ((255, 255, 255, 255), Expected => True);  -- /32

      --  a set bit follows the first cleared bit
      Check_Mask_Validity ((0, 0, 0, 1),         Expected => False);
      Check_Mask_Validity ((0, 255, 255, 255),   Expected => False);
      Check_Mask_Validity ((255, 0, 255, 0),     Expected => False);
      Check_Mask_Validity ((255, 255, 0, 1),     Expected => False);
      Check_Mask_Validity ((255, 255, 253, 0),   Expected => False);
      Check_Mask_Validity ((127, 255, 255, 255), Expected => False);
   end Test_Mask_Validity;

   ------------------------------
   -- Test_Multicast_Detection --
   ------------------------------

   procedure Test_Multicast_Detection is
   begin
      --  class D is 224.0.0.0 .. 239.255.255.255
      Check_Multicast_State (All_Systems,          Expected => True);
      Check_Multicast_State (All_Routers,          Expected => True);
      Check_Multicast_State ((224, 0, 0, 0),       Expected => True);
      Check_Multicast_State ((239, 255, 255, 255), Expected => True);
      Check_Multicast_State ((239, 255, 255, 250), Expected => True);  -- SSDP

      Check_Multicast_State (IP_Unspecified_Address, Expected => False);
      Check_Multicast_State (IP_Broadcast_Address,   Expected => False);
      Check_Multicast_State ((223, 255, 255, 255),   Expected => False);
      Check_Multicast_State ((240, 0, 0, 0),         Expected => False);
      Check_Multicast_State ((192, 168, 1, 1),       Expected => False);
   end Test_Multicast_Detection;

   -------------------------------
   -- Test_Link_Local_Detection --
   -------------------------------

   procedure Test_Link_Local_Detection is
   begin
      --  the link-local block is 169.254.0.0/16
      Check_Link_Local_State ((169, 254, 0, 0),     Expected => True);
      Check_Link_Local_State ((169, 254, 1, 2),     Expected => True);
      Check_Link_Local_State ((169, 254, 255, 255), Expected => True);

      Check_Link_Local_State ((169, 253, 1, 2),     Expected => False);
      Check_Link_Local_State ((169, 255, 1, 2),     Expected => False);
      Check_Link_Local_State ((170, 254, 1, 2),     Expected => False);
      Check_Link_Local_State (IP_Unspecified_Address, Expected => False);
   end Test_Link_Local_Detection;

   ------------------------------------
   -- Test_Multicast_Address_Mapping --
   ------------------------------------

   procedure Test_Multicast_Address_Mapping is
   begin
      --  the low 23 bits of the IP address are carried into 01:00:5E:xx:xx:xx
      Check_Multicast_Mapping (All_Systems,          (16#01#, 16#00#, 16#5E#, 16#00#, 16#00#, 16#01#));
      Check_Multicast_Mapping (All_Routers,          (16#01#, 16#00#, 16#5E#, 16#00#, 16#00#, 16#02#));
      Check_Multicast_Mapping ((239, 255, 255, 250), (16#01#, 16#00#, 16#5E#, 16#7F#, 16#FF#, 16#FA#));
      Check_Multicast_Mapping ((224, 1, 2, 3),       (16#01#, 16#00#, 16#5E#, 16#01#, 16#02#, 16#03#));

      --  bit 24 of the group address is discarded, so these two IP addresses
      --  map onto the same hardware address
      Check_Multicast_Mapping ((224, 128, 1, 2),     (16#01#, 16#00#, 16#5E#, 16#00#, 16#01#, 16#02#));
      Check_Multicast_Mapping ((224, 0, 1, 2),       (16#01#, 16#00#, 16#5E#, 16#00#, 16#01#, 16#02#));
   end Test_Multicast_Address_Mapping;

   -------------------------
   -- Test_Frame_Geometry --
   -------------------------

   procedure Test_Frame_Geometry is
   begin
      Check ("Ethernet_II_Frame_Length_Limit is 1518",
             Ethernet_II_Frame_Length_Limit = 1518, Expected => True);
      Check ("Ethernet_II_Frame_Length'Last covers the limit",
             Ethernet_II_Frame_Length'Last = Ethernet_II_Frame_Length (Ethernet_II_Frame_Length_Limit),
             Expected => True);
      Check ("MTU_Length'Last is the MTU",
             MTU_Length'Last = MTU_Length (Max_Transmission_Unit), Expected => True);
      Check ("Ethernet_Broadcast_Address is not the invalid address",
             Ethernet_Broadcast_Address /= Ethernet_Invalid_Address, Expected => True);
   end Test_Frame_Geometry;

   --------------------
   -- Report_Results --
   --------------------

   procedure Report_Results is
   begin
      New_Line;
      Put_Line (Natural'Image (Cases_Run) & " cases run," &
                Natural'Image (Cases_Failed) & " failed");
      if Cases_Failed = 0 then
         Put_Line ("PASSED");
      else
         Put_Line ("FAILED");
      end if;
   end Report_Results;

begin
   Put_Line ("IEEE_Ethernet host tests");
   Test_Mask_Validity;
   Test_Multicast_Detection;
   Test_Link_Local_Detection;
   Test_Multicast_Address_Mapping;
   Test_Frame_Geometry;
   Report_Results;
end Test_IEEE_Ethernet;
