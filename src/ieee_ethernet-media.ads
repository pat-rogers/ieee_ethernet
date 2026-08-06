-----------------------------------------------------------------------
--  ieee_ethernet-mac_media_signals -- media interfaces and signal counts
--  Copyright (C) 2026 Patrick Rogers (progers@classwide.com)
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

--  This package provides the two interfaces between a MAC and a PHY, and the
--  number of signals comprising each of them. A target maps those signals to
--  the pins carrying them.

package IEEE_Ethernet.Media is

   pragma Pure;

   type Media_Interfaces is (Media_Independent_Interface, Reduced_Media_Independent_Interface);

   MII  : constant Media_Interfaces := Media_Independent_Interface;
   RMII : constant Media_Interfaces := Reduced_Media_Independent_Interface;

   MII_Signal_Count  : constant := 18;
   RMII_Signal_Count : constant := 10;

end IEEE_Ethernet.Media;
