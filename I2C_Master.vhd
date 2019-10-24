----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:11:03 10/15/2019 
-- Design Name: 
-- Module Name:    I2C_Master - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_master is
   Port (clk            : in    STD_LOGIC;
         SDA            : inout STD_LOGIC;
         SCL            : out   STD_LOGIC;
			dataOut			: out   STD_LOGIC_VECTOR (0 to 15));
end I2C_master;

architecture Behavioral of I2C_master is

   type stateType is (idle, ack, startState, writeAddr, writeModeAddr, writeMode, writeReadAddr, writeXRegAddr, 
								readXRegA, readXRegB, readYRegA, readYRegB, readZRegA, readZRegB, stop);
   signal state, nextState    : stateType;
   signal dataCount           : INTEGER RANGE 0 TO 7 := 0;
   signal slaveAddr           : STD_LOGIC_VECTOR (0 to 7) := "00111101"; -- 0x1E(7-bit addr) + 1(1-bit write bit)
   signal modeAddr				: STD_LOGIC_VECTOR (0 to 7) := "00000010";	
	signal modeVal					: STD_LOGIC_VECTOR (0 to 7) := "00000001";
	signal readAddr				: STD_LOGIC_VECTOR (0 to 7) := "00111100";
	signal xAddr					: STD_LOGIC_VECTOR (0 to 7) := "00000011";
	signal xDataRecieved       : STD_LOGIC_VECTOR (0 to 15) := "0000000000000000";
	signal yDataRecieved       : STD_LOGIC_VECTOR (0 to 15) := "0000000000000000";
	signal zDataRecieved       : STD_LOGIC_VECTOR (0 to 15) := "0000000000000000";
	signal stateVar				: STD_LOGIC_VECTOR (10 downto 0);

	signal i_SDA 					: STD_LOGIC := 'Z';
	
	signal count					: integer := 1;
	signal clkVal					: STD_LOGIC := '0';
	signal startVal				: STD_LOGIC := '1';

begin

--------------------------------------------------------------------------------
-- Clock Divider (to 100khz to match compass module)
--------------------------------------------------------------------------------
Clock_Divider: process(clk, count, clkVal)
begin
	if (falling_edge(clk)) then
		count <= count + 1;
		if (count = 500) then
			clkVal <= NOT clkVal;
			count <= 1;
		end if;
	end if;
	SCL <= clkVal;
end process Clock_Divider;

--------------------------------------------------------------------------------
-- State -> Next State
--------------------------------------------------------------------------------
Clock_State: process(clkVal, startVal, state)
begin
	if falling_edge(clkVal) then
		if startVal = '0' then
			state <= nextState;
		end if;
	--elsif rising_edge(clkVal) then
		if startVal = '1' then
			state <= startState;
		end if;
	end if;
end process Clock_State;

--------------------------------------------------------------------------------
-- Start 
--------------------------------------------------------------------------------
Start_Val_Proc: process(clkVal)
begin
	if falling_edge(clkVal) then
		if startVal = '1' then
			startVal <= '0';
		end if;
	end if;
end process Start_Val_Proc;

--------------------------------------------------------------------------------
-- State Machine process
--------------------------------------------------------------------------------
FSM: process(clkVal, state, dataCount, SDA, stateVar)
begin
	if rising_edge(clkVal) then
		case state is
			when startState =>
				nextState <= writeAddr;
			when writeAddr =>          -- "00000000001"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when writeModeAddr =>		-- "00000000010"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when writeMode =>				-- "00000000100"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when writeReadAddr =>		-- "00000001000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when writeXRegAddr =>		-- "00000010000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when readXRegA =>				-- "00000100000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when readXRegB =>				-- "00001000000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when readYRegA =>				-- "00010000000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when readYRegB =>				-- "00100000000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when readZRegA =>				-- "01000000000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when readZRegB =>				-- "10000000000"
				if dataCount = 7 then
					nextState <= ack;
				end if;
			when stop =>
				nextState <= idle;
			when ack =>
				i_SDA <= 'Z';
				case SDA is
					when '0' => -- data ACK by slave
						case stateVar is
							when "00000000001" =>
								nextState <= writeModeAddr;
							when "00000000010" =>
								nextState <= writeMode;
							when "00000000100" =>
								nextState <= writeReadAddr;
							when "00000001000" =>
								nextState <= writeXRegAddr;
							when "00000010000" =>
								nextState <= readXRegA;
							when "00000100000" =>
								nextState <= readXRegB;
							when "00001000000" =>
								nextState <= readYRegA;
							when "00010000000" =>
								nextState <= readYRegB;
							when "00100000000" =>
								nextState <= readZRegA;
							when "01000000000" =>
								nextState <= readZRegB;
							when "10000000000" =>
								nextState <= stop;
							when others =>
								nextState <= idle;
						end case;
					when '1' => -- data NACK by slave
						nextState <= idle;
					when others =>
				end case;
			when others =>
				-- do nothing
		end case;
	end if;
end process FSM;


--------------------------------------------------------------------------------
-- State Variable
--------------------------------------------------------------------------------
State_Var_Proc: process (clkVal, state, SDA)
begin
	if rising_edge(clkVal) then
		case state is
			when writeAddr =>
				stateVar <= "00000000001";
			when writeModeAddr =>
				stateVar <= "00000000010";
			when writeMode =>
				stateVar <= "00000000100";
			when writeReadAddr =>
				stateVar <= "00000001000";
			when writeXRegAddr =>
				stateVar <= "00000010000";
			when readXRegA =>
				stateVar <= "00000100000";
			when readXRegB =>
				stateVar <= "00001000000";
			when readYRegA =>
				stateVar <= "00010000000";
			when readYRegB =>
				stateVar <= "00100000000";
			when readZRegA =>
				stateVar <= "01000000000";
			when readZRegB =>
				stateVar <= "10000000000";
			when others =>
				--do nothing
		end case;
	end if;
	
end process State_Var_Proc;

--------------------------------------------------------------------------------
-- Data Process
--------------------------------------------------------------------------------
FSM_Data: process (clkVal)
begin
	if falling_edge(clkVal) then
		case state is
			when writeAddr =>
				i_SDA <= slaveAddr(dataCount);
			when writeModeAddr =>
				i_SDA <= modeAddr(dataCount);
			when writeMode =>
				i_SDA <= modeVal(dataCount);
			when writeReadAddr =>
				i_SDA <= readAddr(dataCount);
			when writeXRegAddr =>
				i_SDA <= xAddr(dataCount);
			when readXRegA =>
				i_SDA <= 'Z';
				xDataRecieved(dataCount) <= SDA;
			when readXRegB =>
				i_SDA <= 'Z';
				xDataRecieved(dataCount+8) <= SDA;
			when readYRegA =>
				i_SDA <= 'Z';
				yDataRecieved(dataCount) <= SDA;
			when readYRegB =>
				i_SDA <= 'Z';
				yDataRecieved(dataCount+8) <= SDA;
			when readZRegA =>
				i_SDA <= 'Z';
				zDataRecieved(dataCount) <= SDA;
			when readZRegB =>
				i_SDA <= 'Z';
				zDataRecieved(dataCount+8) <= SDA;
			when startState =>
				i_SDA <= 'Z';
				i_SDA <= '0';
			when others =>
		end case;
	end if;
end process FSM_Data;

Data_Proc: process(clkVal, state)
begin
	if rising_edge(clkVal) and state = startState then
		if state = startState then
			i_SDA <= '1';
		end if;
	end if;
end process Data_Proc;

--------------------------------------------------------------------------------
-- Data Counter
--------------------------------------------------------------------------------
FSM_Data_Counter: process(state, clkVal)
begin
   if rising_edge(clkVal) then
      if state = idle or state = ack or (dataCount = 1 and (state = ack or state = startState)) or dataCount = 7 then
         dataCount <= 0;
		else
         dataCount <= dataCount + 1;
      end if;
   end if;
end process FSM_Data_Counter;


sda_buffer: SDA <= i_SDA;
data_buffer: dataOut <= xDataRecieved;

end Behavioral;
