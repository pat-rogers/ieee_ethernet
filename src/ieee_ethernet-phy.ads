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

--  This package defines the abstract interface for any PHY device. Most of the
--  routines provided are concrete, rather than abstract, because there is an
--  international standard for these devices: IEEE 802.3 standard, clause 22
--  (22.2.4.1) specifically.

with IEEE_Ethernet.SMI;     use IEEE_Ethernet.SMI;
with IEEE_Ethernet.SMI.IO;  use IEEE_Ethernet.SMI.IO;
with Ada.Real_Time;         use Ada.Real_Time;

package IEEE_Ethernet.PHY is

   type PHY_Transceiver is abstract tagged limited private;

   type Any_PHY_Transceiver is not null access all PHY_Transceiver'Class
     with Storage_Size => 0;

   procedure Initialize
     (This    : in out PHY_Transceiver;
      Success : out Boolean)
   is abstract
   with Pre'Class => This.SMI_IO_Assigned;

   procedure Set_SMI_IO_Driver
     (This  : in out PHY_Transceiver'Class;
      Value : Any_SMI_IO_Driver)
   with
     Post => This.SMI_IO_Assigned;
   --  Supplies This with the driver it is to use for all subsequent SMI
   --  register access. Call this before any other operation on This.

   function SMI_IO (This : PHY_Transceiver'Class) return Any_SMI_IO_Driver with
     Pre => This.SMI_IO_Assigned,
     Inline;

   function SMI_IO_Assigned (This : PHY_Transceiver'Class) return Boolean with Inline;

   type Operating_Modes is
     (Half_Duplex_10Base_T,
      Half_Duplex_100Base_T,
      Full_Duplex_10Base_T,
      Full_Duplex_100Base_T);

   procedure Get_Operating_Mode
     (This    : PHY_Transceiver;
      Mode    : out Operating_Modes;
      Success : out Boolean)
   is abstract;

   function PHY_Device_Address (This : PHY_Transceiver) return PHY_Address is abstract;

   function Requires_RMII (This : PHY_Transceiver) return Boolean is abstract;

   --  The following routines are class-wide because they are implemented via
   --  the SMI facility and are therefore not vendor-specific.

   procedure Enable_Auto_Negotiation
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean);

   procedure Disable_Auto_Negotiation
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean);

   procedure Restart_Auto_Negotiation
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean);

   procedure Query_Auto_Negotiation_Enabled
     (This    : PHY_Transceiver'Class;
      Enabled : out Boolean;
      Success : out Boolean);

   procedure Query_Auto_Negotiation_Supported
     (This      : PHY_Transceiver'Class;
      Supported : out Boolean;
      Success   : out Boolean);

   procedure Query_Auto_Negotiation_Complete
     (This     : PHY_Transceiver'Class;
      Complete : out Boolean;
      Success  : out Boolean);

   procedure Power_Down (This : PHY_Transceiver'Class);
   --  The entire transceiver enters a low power consumption mode, except for
   --  the management interface (eg, so that it can be powered back up).

   procedure Power_Up (This : PHY_Transceiver'Class);
   --  Exit the low-power consumption mode and automatically reset.

   procedure Enable_Loopback_Mode
     (This    : PHY_Transceiver'Class;
      Success : out Boolean);

   procedure Disable_Loopback_Mode
     (This    : PHY_Transceiver'Class;
      Success : out Boolean);

   procedure Force_Configuration
     (This                : in out PHY_Transceiver'Class;
      Fast_Ethernet_Speed : Boolean;  --  True -> 100 Mbit/s, False -> 10 Mbit/s
      Full_Duplex_Mode    : Boolean;
      Success             : out Boolean);
   --  Use of this routine is strongly discouraged with modern hardware, and
   --  with Fiber cannot be used at all.

   procedure Reset_Transceiver (This : in out PHY_Transceiver'Class; Success : out Boolean);

   procedure Query_Link_State
     (This     : PHY_Transceiver'Class;
      Is_Up    : out Boolean;
      Success  : out Boolean);

   Max_Convergence_Interval : constant Time_Span := Seconds (5);
   --  The expected upper bound for the auto negotiation to have converged on
   --  agreement. It should take roughly two or three seconds, so more than
   --  that should be plenty.

   Completion_Poll_Interval : constant Time_Span := Milliseconds (24);
   --  This period is sufficient for two FLP bursts to have been sent by
   --  the PHYs during the negotiation process so is more than enough for a
   --  possible state change. There's no point in querying the completion
   --  too quickly... See IEEE 802.3 Clause 28.

   procedure Await_Auto_Negotiation_Completion
     (This                 : in out PHY_Transceiver'Class;
      Success              : out Boolean;
      Convergence_Interval : Time_Span := Max_Convergence_Interval;
      Poll_Interval        : Time_Span := Completion_Poll_Interval)
   with
     Pre => Convergence_Interval > Time_Span_Zero and then
            Poll_Interval > Time_Span_Zero        and then
            Poll_Interval <= Convergence_Interval;
   --  Waits no more than Convergence_Interval. Queries the PHY at a period
   --  of Poll_Interval.

   procedure Negotiate_Speed_And_Duplex_Mode
     (This    : in out PHY_Transceiver'Class;
      Success : out Boolean);
   --  If This PHY has auto-negotiation enabled then just wait for it to
   --  complete, setting Success to False if that times-out, True otherwise.
   --  If the PHY does not have auto-negotiation enabled, start the
   --  auto-configuration steps manually, again setting Success as the
   --  steps proceed, returning immediately if any step fails.

private

   type SMI_IO_Driver_Reference is access all SMI_IO_Driver'Class with Storage_Size => 0;

   type PHY_Transceiver is abstract tagged limited record
      Driver : SMI_IO_Driver_Reference;
   end record;

end IEEE_Ethernet.PHY;
