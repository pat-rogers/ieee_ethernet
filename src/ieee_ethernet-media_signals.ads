-----------------------------------------------------------------------
--  ieee_ethernet-media_signals -- MII and RMII signal names
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

--  This package provides the names of the signals comprising the Media
--  Independent Interface and its reduced form, as defined by IEEE 802.3.
--  A target maps these names to the pins carrying them.

package IEEE_Ethernet.Media_Signals is

   pragma Pure;

   type MII_Signal_Names is
     (MII_MDIO,
      MII_MDC,
      MII_TX_CLK,
      MII_TXD0,
      MII_TXD1,
      MII_TXD2,
      MII_TXD3,
      MII_TX_EN,
      MII_TX_ER,
      MII_RX_CLK,
      MII_RXD0,
      MII_RXD1,
      MII_RXD2,
      MII_RXD3,
      MII_RX_DV,
      MII_RX_ER,
      MII_CRS,
      MII_COL);

   type RMII_Signal_Names is
     (RMII_REF_CLK,
      RMII_MDIO,
      RMII_MDC,
      RMII_CRS_DV,
      RMII_RXD0,
      RMII_RXD1,
      RMII_RXER,
      RMII_TX_EN,
      RMII_TXD0,
      RMII_TXD1);

end IEEE_Ethernet.Media_Signals;
