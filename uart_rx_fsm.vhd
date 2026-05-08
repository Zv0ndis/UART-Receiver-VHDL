-- uart_rx_fsm.vhd: UART controller - finite state machine for RX side
-- Author(s): Zvonicek Tomas (xzvonit00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
        CLK          : in std_logic;
        RST          : in std_logic;
        DIN          : in std_logic;
        CNT          : in std_logic_vector(3 downto 0);
        BIT_CNT      : in std_logic_vector(3 downto 0);
        CNT_EN       : out std_logic;
        CNT_RST      : out std_logic;
        BIT_CNT_EN   : out std_logic;
        BIT_CNT_RST  : out std_logic;
        DATA_EN      : out std_logic;
        DOUT_VLD     : out std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is
    -- FSM states
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT, DATA_VALID);
    signal state : state_type := IDLE;
    signal next_state : state_type := IDLE;
begin

    state_reg: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
            else
                state <= next_state;
            end if;
        end if;
    end process;
    
    next_state_logic: process(state, DIN, CNT, BIT_CNT)
    begin
        CNT_EN <= '0';
        CNT_RST <= '0';
        BIT_CNT_EN <= '0';
        BIT_CNT_RST <= '0';
        DATA_EN <= '0';
        DOUT_VLD <= '0';
        
        case state is
            
            when IDLE =>
                CNT_RST <= '1';
                BIT_CNT_RST <= '1';
                if DIN = '0' then
                    next_state <= START_BIT;
                else
                    next_state <= IDLE;
                end if;

            when START_BIT =>
                CNT_EN <= '1';
                if CNT = "0111" then
                    if DIN = '0' then
                        next_state <= DATA_BITS;
                        CNT_RST <= '1'; 
                    else
                        next_state <= IDLE;
                    end if;
                else
                    next_state <= START_BIT;
                end if;

            when DATA_BITS =>
                CNT_EN <= '1';
                if CNT = "1111" then
                    DATA_EN <= '1';
                    BIT_CNT_EN <= '1';
                    if BIT_CNT = "0111" then  
                        next_state <= STOP_BIT;
                        CNT_RST <= '1'; 
                    else
                        next_state <= DATA_BITS;
                        CNT_RST <= '1'; 
                    end if;
                else
                    next_state <= DATA_BITS;
                end if;
        
            when STOP_BIT =>
                CNT_EN <= '1';
                if CNT = "1111" then
                    if DIN = '1' then
                        next_state <= DATA_VALID;
                    else
                        next_state <= IDLE;
                    end if;
                else
                    next_state <= STOP_BIT;
                end if;

            when DATA_VALID =>
                DOUT_VLD <= '1';
                next_state <= IDLE;
            
            when others =>
                next_state <= IDLE;
        end case;
    end process;
    
end architecture;