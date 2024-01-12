library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity critical_path is
    Port (max_height : in std_logic_vector(7 downto 0);
          z : in std_logic_vector(2 downto 0);
          clk : in std_logic;
          reset : in std_logic;
          output : out std_logic_vector(10 downto 0));
end critical_path;

architecture Behavioral of critical_path is

signal max_height_reg, max_height_next : std_logic_vector(7 downto 0);
signal z_reg, z_next : std_logic_vector(2 downto 0);
signal currY_reg, currY_next : std_logic_vector(10 downto 0);
signal en_mul, en_add : std_logic;
signal input1_add, input2_add : std_logic_vector(10 downto 0);
signal output_add : std_logic_vector(11 downto 0);
signal input1_mul, input2_mul : std_logic_vector(7 downto 0);
signal output_mul : std_logic_vector(15 downto 0);

begin

process(clk) is
begin
    if(rising_edge(clk)) then
        if(reset = '1') then
            max_height_reg <= (others => '0');
            z_reg <= (others => '0');
            currY_reg <= (others => '0');
        else
            max_height_reg <= max_height_next;
            z_reg <= z_next;
            currY_reg <= currY_next;
        end if;
    end if;
end process;

max_height_next <= max_height;
z_next <= z;

en_mul <= '1';
input1_mul <= "00000" & z_reg;
input2_mul <= max_height_reg;

en_add <= '1';
input1_add <= "0000" & max_height_reg(7 downto 1);
input2_add <= output_mul(10 downto 0);
currY_next <= output_add(10 downto 0);

output <= currY_reg;

mul1: entity work.multiplier
    generic map (WIDTH => 8)
    port map(
            en => en_mul,
            input_1 => input1_mul,
            input_2 => input2_mul,
            output => output_mul
            );
            
adder1: entity work.adder
    generic map (WIDTH => 11)
    port map(
            en => en_add,
            input_1 => input1_add,
            input_2 => input2_add,
            output => output_add
            );
            

end Behavioral;
