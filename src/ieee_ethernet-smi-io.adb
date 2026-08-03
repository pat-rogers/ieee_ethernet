-----------------------------------------------------------------------
--  ieee_ethernet-smi.io -- Ethernet SMI I/O
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

package body IEEE_Ethernet.SMI.IO is

   function As_Basic_Status_Register is new Ada.Unchecked_Conversion
     (Source => Register_Value, Target => Basic_Status_Register);

   function As_Basic_Control_Register is new Ada.Unchecked_Conversion
     (Source => Register_Value, Target => Basic_Control_Register);

   function As_Register_Value is new Ada.Unchecked_Conversion
     (Source => Basic_Control_Register, Target => Register_Value);

   -------------
   -- Get_BCR --
   -------------

   procedure Get_BCR
     (This    : Any_SMI_IO_Driver;
      PHY     : PHY_Address;
      Value   : in out Basic_Control_Register;
      Success : out Boolean)
   is
      Content  : Register_Value;
   begin
      This.Read_SMI_Register (PHY, SMI_BCR, Content, Success);
      if Success then
         Value := As_Basic_Control_Register (Content);
      end if;
   end Get_BCR;

   -------------
   -- Put_BCR --
   -------------

   procedure Put_BCR
     (This    : Any_SMI_IO_Driver;
      PHY     : PHY_Address;
      Value   : Basic_Control_Register;
      Success : out Boolean)
   is
   begin
      This.Write_SMI_Register (PHY, SMI_BCR, As_Register_Value (Value), Success);
   end Put_BCR;

   -------------
   -- Get_BSR --
   -------------

   procedure Get_BSR
     (This    : Any_SMI_IO_Driver;
      PHY     : PHY_Address;
      Value   : in out Basic_Status_Register;
      Success : out Boolean)
   is
      Content  : Register_Value;
   begin
      This.Read_SMI_Register (PHY, SMI_BSR, Content, Success);
      if Success then
         Value := As_Basic_Status_Register (Content);
      end if;
   end Get_BSR;

end IEEE_Ethernet.SMI.IO;
