-----------------------------------------------------------------------
--  ieee_ethernet-smi-io -- Ethernet SMI I/O
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

--  This package defines the abstract interface for how to read and write SMI
--  registers. It will be overridden by a concrete MCU-family specific type.
--  Concrete convenience routines are also provided.

package IEEE_Ethernet.SMI.IO is

   type SMI_IO_Driver is abstract tagged limited private;

   type Any_SMI_IO_Driver is not null access all SMI_IO_Driver'Class;

   --  The following are abstract SMI I/O routines for any given PHY
   --  and register index. These will be defined as concrete overridings for
   --  target-specific I/O on SMI registers, eg the STM32 boards.

   type Register_Value is mod 2 ** 16;

   procedure Read_SMI_Register
     (This     : not null access SMI_IO_Driver;
      PHY      : PHY_Address;
      Register : Register_Index;
      Value    : out Register_Value;
      Success  : out Boolean)
   is abstract;

   procedure Write_SMI_Register
     (This     : not null access SMI_IO_Driver;
      PHY      : PHY_Address;
      Register : Register_Index;
      Value    : Register_Value;
      Success  : out Boolean)
   is abstract;

   --  The following are concrete classwide routines for doing I/O in terms
   --  of the register record types, for convenience. They call (dynamically
   --  dispatch to) the two abstract routines defined above.

   procedure Get_BCR
     (This    : Any_SMI_IO_Driver;
      PHY     : PHY_Address;
      Value   : in out Basic_Control_Register;
      Success : out Boolean)
   with Inline;
   --  Attempt to read the Basic_Control_Register

   procedure Put_BCR
     (This    : Any_SMI_IO_Driver;
      PHY     : PHY_Address;
      Value   : Basic_Control_Register;
      Success : out Boolean)
   with Inline;
   --  Attempt to write to the Basic_Control_Register

   procedure Get_BSR
     (This    : Any_SMI_IO_Driver;
      PHY     : PHY_Address;
      Value   : in out Basic_Status_Register;
      Success : out Boolean)
   with Inline;
   --  Attempt to read the Basic_Status_Register

private

   type SMI_IO_Driver is abstract tagged limited null record;

end IEEE_Ethernet.SMI.IO;
