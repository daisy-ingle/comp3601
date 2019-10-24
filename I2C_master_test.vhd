--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:44:43 10/16/2019
-- Design Name:   
-- Module Name:   C:/Users/Jacob/Documents/COMP3601/Compass/I2C_master_test.vhd
-- Project Name:  Compass
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: I2C_master
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY I2C_master_test IS
END I2C_master_test;
 
ARCHITECTURE behavior OF I2C_master_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT I2C_master
    PORT(
         clk 			: IN   std_logic;
         SDA   		: INOUT   std_logic;
         SCL    		: OUT   std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk       : std_logic := '0';
	
	--Input/Outputs
   signal SDA       : std_logic := 'Z';

 	--Outputs
   signal SCL       : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	--signal o_SDA	  : std_logic := 'Z';
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: I2C_master PORT MAP (
          clk        => clk,
          SDA        => SDA,
          SCL        => SCL
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		
		-- simulate ACKs from slave
		wait for clk_period*9*1000;
		SDA <= '0';
		wait for clk_period*1000;
		SDA <= 'Z';
		wait for clk_period*8*1000;
		SDA <= '0';
		wait for clk_period*1000;
		SDA <= 'Z';
		wait for clk_period*8*1000;
		SDA <= '0';
		wait for clk_period*1000;
		SDA <= 'Z';
		wait for clk_period*8*1000;
		SDA <= '0';
		wait for clk_period*1000;
		SDA <= 'Z';
		wait for clk_period*8*1000;
		SDA <= '0';
		wait for clk_period*1000;
		
		-- simulate data in from slave
      wait for clk_period*9*1000;
		SDA <= 'Z';
		SDA <= '1';
		wait for clk_period*1000;
		SDA <= 'Z';
		SDA <= '0';
		wait for clk_period*1000;
		SDA <= 'Z';
		SDA <= '1';
		wait for clk_period*1000;
		SDA <= 'Z';
		SDA <= '0';
		wait for clk_period*1000;


      wait;
   end process;

END;
