-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Zvonicek Tomas (xzvonit00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation
architecture behavioral of UART_RX is
    signal cnt_en      : std_logic;
    signal cnt_rst     : std_logic;
    signal bit_cnt_en  : std_logic;
    signal bit_cnt_rst : std_logic;
    signal data_en     : std_logic;
    signal vld         : std_logic;
    

    signal cnt : std_logic_vector(3 downto 0);
    
    signal bit_cnt : std_logic_vector(3 downto 0);
    
    signal data_reg : std_logic_vector(7 downto 0);
begin


    fsm: entity work.UART_RX_FSM
    port map (
        CLK         => CLK,
        RST         => RST,
        DIN         => DIN,
        CNT         => cnt,
        BIT_CNT     => bit_cnt,
        CNT_EN      => cnt_en,
        CNT_RST     => cnt_rst,
        BIT_CNT_EN  => bit_cnt_en,
        BIT_CNT_RST => bit_cnt_rst,
        DATA_EN     => data_en,
        DOUT_VLD    => vld
    );

    clock_counter: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' or cnt_rst = '1' then
                cnt <= (others => '0');
            elsif cnt_en = '1' then
                cnt <= cnt + 1;
            end if;
        end if;
    end process;
    
    bit_counter: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' or bit_cnt_rst = '1' then
                bit_cnt <= (others => '0');
            elsif bit_cnt_en = '1' then
                bit_cnt <= bit_cnt + 1;
            end if;
        end if;
    end process;
    
    data_register: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                data_reg <= (others => '0');
            elsif data_en = '1' then
                data_reg <= DIN & data_reg(7 downto 1);
            end if;
        end if;
    end process;

    DOUT <= data_reg;
    DOUT_VLD <= vld;

end architecture;