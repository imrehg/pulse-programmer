library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_sram is

  port (
    SRAM_DQA8  : inout std_logic;
    SRAM_DQA7  : inout std_logic;
    SRAM_DQA6  : inout std_logic;
    SRAM_DQA5  : inout std_logic;
    SRAM_DQA4  : inout std_logic;
    SRAM_DQA3  : inout std_logic;
    SRAM_DQA2  : inout std_logic;
    SRAM_DQA1  : inout std_logic;
    SRAM_DQA0  : inout std_logic;
    SRAM_A0    : out   std_logic;
    SRAM_A1    : out   std_logic;
    SRAM_A2    : out   std_logic;
    SRAM_A3    : out   std_logic;
    SRAM_A4    : out   std_logic;
    SRAM_A5    : out   std_logic;
    SRAM_A6    : out   std_logic;
    SRAM_A7    : out   std_logic;
    SRAM_A8    : out   std_logic;
    SRAM_A9    : out   std_logic;
    SRAM_A10   : out   std_logic;
    SRAM_A11   : out   std_logic;
    SRAM_A12   : out   std_logic;
    SRAM_A13   : out   std_logic;
    SRAM_A14   : out   std_logic;
    SRAM_A15   : out   std_logic;
    SRAM_A16   : out   std_logic;
    SRAM_A17   : out   std_logic;
    SRAM_A18   : out   std_logic;
    SRAM_A19   : out   std_logic;
    SRAM_nADSC : out   std_logic;
    SRAM_nOE   : out   std_logic;
    SRAM_nGW   : out   std_logic;
    SRAM_nCE1  : out   std_logic;
    SRAM_DQB8  : inout std_logic;
    SRAM_DQB7  : inout std_logic;
    SRAM_DQB6  : inout std_logic;
    SRAM_DQB5  : inout std_logic;
    SRAM_DQB4  : inout std_logic;
    SRAM_DQB3  : inout std_logic;
    SRAM_DQB2  : inout std_logic;
    SRAM_DQB1  : inout std_logic;
    SRAM_DQB0  : inout std_logic;
    );

end test_sram;

architecture behaviour of test_sram is
begin
  
end behaviour;
