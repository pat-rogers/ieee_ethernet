-----------------------------------------------------------------------
--  ieee_ethernet-phy -- Ethernet PHY transceiver abstraction
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

package body IEEE_Ethernet.PHY is

   -----------------------
   -- Set_SMI_IO_Driver --
   -----------------------

   procedure Set_SMI_IO_Driver
     (This  : in out PHY_Transceiver'Class;
      Value : Any_SMI_IO_Driver)
   is
   begin
      This.Driver := SMI_IO_Driver_Reference (Value);
   end Set_SMI_IO_Driver;

   ------------
   -- SMI_IO --
   ------------

   function SMI_IO (This : PHY_Transceiver'Class) return Any_SMI_IO_Driver is
     (Any_SMI_IO_Driver (This.Driver));

   ---------------------
   -- SMI_IO_Assigned --
   ---------------------

   function SMI_IO_Assigned (This : PHY_Transceiver'Class) return Boolean is
     (This.Driver /= null);

   -----------------------
   -- Reset_Transceiver --
   -----------------------

   procedure Reset_Transceiver
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean)
   is
      Deadline    : Time;
      BCR_Content : Basic_Control_Register;

      PHY_Reset_Max_Interval  : constant Time_Span := Milliseconds (500);
      --  Per the IEEE 802.3 standard, clause 22 (22.2.4.1)
   begin
      --  We don't care what the other bits were because we are resetting, but
      --  we're not supposed to set any other bits when setting this one (per
      --  the datasheet). That's the case because the default component values
      --  are all effectively zeros.
      BCR_Content := Basic_Control_Register'(Soft_Reset => True, others => <>);
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, BCR_Content, Success);
      if not Success then
         return;
      end if;
      --  The Soft_Reset bit is self-clearing, per the standard, so we wait
      --  for it to clear.
      Deadline := Clock + PHY_Reset_Max_Interval;
      while Clock < Deadline loop
         Get_BCR (This.SMI_IO, This.PHY_Device_Address, BCR_Content, Success);
         if not Success then
            return;
         end if;
         exit when not BCR_Content.Soft_Reset;
      end loop;
      Success := not BCR_Content.Soft_Reset;
   end Reset_Transceiver;

   -----------------------------
   -- Enable_Auto_Negotiation --
   -----------------------------

   procedure Enable_Auto_Negotiation
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean)
   is
      Content : Basic_Control_Register;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Enable Auto-Negotiation timeout";
      end if;
      Content.Auto_Negotiation_Enable := True;
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
   end Enable_Auto_Negotiation;

   ------------------------------
   -- Disable_Auto_Negotiation --
   ------------------------------

   procedure Disable_Auto_Negotiation
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean)
   is
      Content : Basic_Control_Register;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Disable Auto-Negotiation timeout";
      end if;
      Content.Auto_Negotiation_Enable := False;
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
   end Disable_Auto_Negotiation;

   --------------------------------------
   -- Query_Auto_Negotiation_Supported --
   --------------------------------------

   procedure Query_Auto_Negotiation_Supported
     (This     : PHY_Transceiver'Class;
     Supported : out Boolean;
     Success   : out Boolean)
   is
      Content : Basic_Status_Register;
   begin
      Get_BSR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Auto_Negotiation_Supported timeout";
      end if;
      Supported := Content.Supports_Auto_Negotiation;
   end Query_Auto_Negotiation_Supported;

   -------------------------------------
   -- Query_Auto_Negotiation_Complete --
   -------------------------------------

   procedure Query_Auto_Negotiation_Complete
     (This    : PHY_Transceiver'Class;
     Complete : out Boolean;
     Success  : out Boolean)
   is
      Content : Basic_Status_Register;
   begin
      Get_BSR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Query negotiation complete timeout";
      end if;
      Complete := Content.Auto_Negotiation_Complete;
   end Query_Auto_Negotiation_Complete;

   ------------------------------------
   -- Query_Auto_Negotiation_Enabled --
   ------------------------------------

   procedure Query_Auto_Negotiation_Enabled
     (This   : PHY_Transceiver'Class;
     Enabled : out Boolean;
     Success : out Boolean)
   is
      Content : Basic_Control_Register;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Auto_Negotiation_Enabled timeout";
      end if;
      Enabled := Content.Auto_Negotiation_Enable;
   end Query_Auto_Negotiation_Enabled;

   ------------------------------
   -- Restart_Auto_Negotiation --
   ------------------------------

   procedure Restart_Auto_Negotiation
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean)
   is
      Content : Basic_Control_Register;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Restart_Auto_Negotiation timeout";
      end if;
      Content.Restart_Auto_Negotiation := True;
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
   end Restart_Auto_Negotiation;

   ----------------
   -- Power_Down --
   ----------------

   procedure Power_Down (This : PHY_Transceiver'Class) is
      Content : Basic_Control_Register;
      Success : Boolean;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Power Down timeout";
      end if;
      Content.Power_Down_Mode := Power_Down;
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
   end Power_Down;

   --------------
   -- Power_Up --
   --------------

   procedure Power_Up (This : PHY_Transceiver'Class) is
      Content : Basic_Control_Register;
      Success : Boolean;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Power Up timeout";
      end if;
      Content.Power_Down_Mode := Normal_Operation;
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
   end Power_Up;

   -------------------------
   -- Force_Configuration --
   -------------------------

   procedure Force_Configuration
     (This                : in out PHY_Transceiver'Class;
      Fast_Ethernet_Speed : Boolean;
      Full_Duplex_Mode    : Boolean;
      Success             : out Boolean)
   is
      Content : Basic_Control_Register;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         return; -- "Force_Configure timeout";
      end if;
      Content.Auto_Negotiation_Enable := False;
      Content.Speed_Select  := (if Fast_Ethernet_Speed then High_100Mbps else Low_10Mbps);
      Content.Duplex_Select := (if Full_Duplex_Mode then Full_Duplex else Half_Duplex);
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
   end Force_Configuration;

   ----------------------
   -- Query_Link_State --
   ----------------------

   procedure Query_Link_State
     (This     : PHY_Transceiver'Class;
      Is_Up    : out Boolean;
      Success  : out Boolean)
   is
      Content : Basic_Status_Register;
   begin
      --  Per IEEE 802.3, PHY Register 1h, Bit #2 for the Link Status is a
      --  latched-low bit. Whenever the PHY detects a link-up to link-down
      --  status transition, the Link Status bit will retain the 0 value for
      --  link-down and the latch is only cleared after it is read (so that
      --  transients are captured). The read that clears the latch reports
      --  the latched 0, so the next read is the one that reports the
      --  current state. Hence a 0 is ambiguous and requires that second
      --  read, but a 1 does not: the bit could not read 1 if a
      --  down-transition had occurred since the previous read.
      Get_BSR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         Is_Up := False; -- give it a defined value since it is a scalar...
         return; -- "Link status read timeout";
      end if;

      Is_Up := Content.Link_Is_Up;
      if Is_Up then -- we're good to go, no need to read again
         return;
      end if;

      Get_BSR (This.SMI_IO, This.PHY_Device_Address, Content, Success);
      if not Success then
         --  Is_Up is False here, already
         return; -- "Link status read timeout";
      end if;
      Is_Up := Content.Link_Is_Up;
   end Query_Link_State;

   --------------------------
   -- Enable_Loopback_Mode --
   --------------------------

   procedure Enable_Loopback_Mode
     (This    : PHY_Transceiver'Class;
      Success : out Boolean)
   is
      BCR_Content : Basic_Control_Register;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, BCR_Content, Success);
      if not Success then
         return; -- "Enable_Loopback_Mode timeout";
      end if;
      BCR_Content.Loopback_Mode := Loopback;
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, BCR_Content, Success);
   end Enable_Loopback_Mode;

   ---------------------------
   -- Disable_Loopback_Mode --
   ---------------------------

   procedure Disable_Loopback_Mode
     (This    : PHY_Transceiver'Class;
      Success : out Boolean)
   is
      BCR_Content : Basic_Control_Register;
   begin
      Get_BCR (This.SMI_IO, This.PHY_Device_Address, BCR_Content, Success);
      if not Success then
         return; -- "Disable_Loopback_Mode timeout";
      end if;
      BCR_Content.Loopback_Mode := Normal;
      Put_BCR (This.SMI_IO, This.PHY_Device_Address, BCR_Content, Success);
   end Disable_Loopback_Mode;

   -------------------------------------
   -- Negotiate_Speed_And_Duplex_Mode --
   -------------------------------------

   procedure Negotiate_Speed_And_Duplex_Mode
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean)
   is
      Enabled : Boolean;
   begin
      This.Query_Auto_Negotiation_Enabled (Enabled, Success);
      if not Success then
         return;
      end if;
      if Enabled then
         --  the PHY will automatically be doing an auto-negotiation on
         --  powerup, so we just wait
         This.Await_Auto_Negotiation_Completion (Success);
      else  -- start a negotiation
         This.Enable_Auto_Negotiation (Success);
         if not Success then
            return;
         end if;
         This.Restart_Auto_Negotiation (Success);
         if not Success then
            return;
         end if;
         This.Await_Auto_Negotiation_Completion (Success);
      end if;
   end Negotiate_Speed_And_Duplex_Mode;

   ---------------------------------------
   -- Await_Auto_Negotiation_Completion --
   ---------------------------------------

   procedure Await_Auto_Negotiation_Completion
     (This                 : in out PHY_Transceiver'Class;
      Success              : out Boolean;
      Convergence_Interval : Time_Span := Max_Convergence_Interval;
      Poll_Interval        : Time_Span := Completion_Poll_Interval)
   is
      Deadline : constant Time := Clock + Convergence_Interval;
      Complete : Boolean;
   begin
      loop
         Query_Auto_Negotiation_Complete (This, Complete, Success);
         if not Success then
            return;
         end if;
         exit when Complete;
         if Clock > Deadline then
            Success := False;
            return;
         end if;
         delay until Clock + Poll_Interval;
      end loop;
      Success := True;
   end Await_Auto_Negotiation_Completion;

   ----------------------------
   -- Confirm_Device_Present --
   ----------------------------

   procedure Confirm_Device_Present
     (This       : PHY_Transceiver'Class;
      At_Address : PHY_Address;
      Success    : out Boolean)
   is
      ID_High : SMI.IO.Register_Value;
      ID_Low  : SMI.IO.Register_Value;

      Gated_Clock_Reading  : constant SMI.IO.Register_Value := 16#0000#;
      Floating_Bus_Reading : constant SMI.IO.Register_Value := 16#FFFF#;
   begin
      --  A live PHY returns fixed, nonzero identifier words in registers 2
      --  and 3. A gated MAC clock reads all-zeros and a floating bus reads
      --  all-ones; neither can come from a real device, so reject both. This
      --  is not an identity check -- the vendor ships several OUIs -- it only
      --  confirms that something is answering, which Read_SMI_Register's
      --  Success alone does not tell us (that reports only that the MII Busy
      --  bit cleared).
      This.SMI_IO.Read_SMI_Register (At_Address, SMI_PHYI1R, ID_High, Success);
      if not Success then
         return;
      end if;
      This.SMI_IO.Read_SMI_Register (At_Address, SMI_PHYI2R, ID_Low, Success);
      if not Success then
         return;
      end if;
      Success := not (ID_High = Gated_Clock_Reading and then ID_Low = Gated_Clock_Reading) and then
                 not (ID_High = Floating_Bus_Reading and then ID_Low = Floating_Bus_Reading);
   end Confirm_Device_Present;

end IEEE_Ethernet.PHY;
