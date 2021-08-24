----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Newton Jr
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library mito;
use mito.mito_pkg.all;


entity testebench is

end testebench;

architecture Behavioral of testebench is

    component miTo is
    port (
         rst                    : in  std_logic;
         clk                    : in  std_logic;
         halt                   : out  std_logic         
    ); 
    
    end component;   
     
        -- control signals
        signal clk_s            : std_logic :='0';
        signal reset_s          : std_logic;
        signal halt_s          : std_logic;
        
    begin
    
      miTo_i : miTo
      port map(
        clk                 => clk_s,
        rst                 => reset_s,   
        halt                => halt_s
      );

    -- clock generator - 100MHZ
    clk_s 	<= not clk_s after 5 ns;
    
    -- reset signal
    reset_s		<= '1' after 2 ns,
		   '0' after 10 ns;	

end Behavioral;
