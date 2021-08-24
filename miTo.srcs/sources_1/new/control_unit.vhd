----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Vitor Aspirot
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library mito;
use mito.mito_pkg.all;

entity control_unit is
    Port ( 
        clk                 : in  std_logic; -- clock  
        rst                 : in  std_logic; -- reset
        halt                : out std_logic; -- sinal de parada para o testbench
        pc_mux              : out std_logic; -- mux, se passa o endereco do adder ou o incluido na instrucao
        pc_en               : out std_logic; -- mux, para saber se será incrementado 1 ou o endereço vira do jump
        i_or_d              : out std_logic; -- mux, se o endereco e' de intrucao ou dado
        mem_write           : out std_logic; -- escrevendo na memoria, se 0 ta lendo
        ir_en               : out std_logic; -- habilitador do IR  
        mdr_en              : out std_logic; -- habilitador do MDR  
        mem_to_reg          : out std_logic; -- mux, se o dado vem do MDR ou do R    
        reg_dst             : out std_logic;
        reg_write           : out std_logic; -- escrevendo no registrador, se 0 ta lendo
        ra_en               : out std_logic; -- registrador A
        rb_en               : out std_logic; -- registrador B
        rr_en               : out std_logic; -- regristrado R  
        addst_en            : out std_logic;
        flag_z              : in  std_logic; -- flag de resultado zero na ula  
        opcode              : in  decoded_instruction_type; -- opcode da instrucao                   
        alu_op              : out std_logic_vector (2 downto 0) -- opcode da ula
    );
end control_unit;

architecture rtl of control_unit is
    type state is (start, load, load2, stateOne, stateTwo, opControl, rState, store, store2, addst, beq1, beq2, writeReg, fim, fimB, jump, hlt);  -- estados
	signal current: state;
	signal nextState: state;
begin
    main: process(clk)
    begin
        if(clk'event and clk = '1')then
            if(rst = '1')then
                current <= start;
            else
                current <= nextState;
            end if;
        end if;
    end process main;

    next_state: process(current, opcode, flag_z)
    begin
           case current is
                when start =>
                    halt        <= '0';
                    pc_mux      <= '0';
                    pc_en       <= '0';
                    i_or_d      <= '0';
                    mem_write   <= '0';
                    ir_en       <= '0';
                    mdr_en      <= '0';
                    mem_to_reg  <= '0';
                    reg_dst     <= '0';
                    reg_write   <= '0';
                    ra_en       <= '0';
                    rb_en       <= '0';
                    rr_en       <= '0';
                    addst_en    <= '0';
                    alu_op      <= "000";
                    nextState   <= stateOne;
                
                when stateOne =>
                    reg_write <= '0';
                    pc_en <= '0';
                    pc_mux <= '0';
                    i_or_d <= '0';
                    nextState <= stateTwo;
                
                when stateTwo =>
                    ir_en <= '1';            
                    nextState <= opControl;
                
                when opControl => 
                    ir_en <= '0';              
                    case opcode is
                        when I_ADD =>
                            alu_op <= "000";   
                            ra_en <= '1';                           
                            rb_en <= '1';
                            pc_mux <= '0';
                            nextState <= rState;
                         
                        when I_SUB =>
                            alu_op <= "001";                              
                            ra_en <= '1';                           
                            rb_en <= '1';
                            pc_mux <= '0';
                            nextState <= rState;
                        
                        when I_JMP =>
                            pc_mux <= '1';
                            nextState <= jump;
                            
                        when I_BEQ =>
                            alu_op <= "001";
                            ra_en <= '1';                           
                            rb_en <= '1';
                            pc_mux <= '0';
                            nextState <= beq1;
                            
                        when I_LOAD =>
                            i_or_d <= '1';
                            ra_en <= '0';                           
                            rb_en <= '0';
                            nextState <= load;
                            
                        when I_STORE =>
                            ra_en <= '1';
                            i_or_d <= '1';
                            nextState <= store;
                            
                       when I_ADDST =>
                            alu_op <= "000"; 
                            ra_en <= '1';
                            rb_en <= '1';
                            i_or_d <= '1';
                            nextState <= addst;
                           
                        when I_HALT =>
                            ra_en <= '0';                           
                            rb_en <= '0';
                            nextState <= hlt;
                        
                        when others =>
                            nextState <= hlt;
                    end case;
                
                when addst =>
                    rr_en <= '1';
                    addst_en <= '1';
                    nextState <= store;
                    
                when load =>
                    mdr_en <= '1';    
                    nextState <= load2;
                    
                when load2 =>
                    mdr_en <= '0';
                    mem_to_reg <= '1';
                    reg_write <= '1';
                    nextState <= fim;   
                    
                when rState =>
                    rr_en <= '1';
                    nextState <= writeReg;
                   
                when beq1 =>
                    rr_en <= '1';
                    nextState <= beq2;
                    
                when beq2 =>
                    ra_en <= '0';
                    rb_en <= '0';
                    nextState <= fimB;
                    
                when store =>
                    mem_write <= '1';
                    nextState <= store2;
                 
                when store2 =>
                    ra_en <= '0';
                    rb_en <= '0';
                    nextState <= fim;
                               
                when writeReg =>
                    ra_en <= '0';                           
                    rb_en <= '0';
                    mem_to_reg <= '0';
                    reg_write <= '1';
                    nextState <= fim;
                        
                when fim =>
                    mem_write <= '0';
                    rr_en <= '0';     
                    pc_mux <= '0';
                    pc_en <= '1';
                    nextState <= stateOne;  
                
                when fimB =>
                    if(flag_z = '1')then
                        pc_mux <= '1';
                        nextState <= jump;
                    else
                        pc_mux <= '0';
                        nextState <= fim;
                    end if;        
                                                                           
                when jump =>
                    pc_en <= '1';
                    nextState <= stateOne;
                
                when hlt =>
                    halt <= '1';
                    nextState <= hlt;      
                                                                      
                when others =>
                    nextState <= stateOne;
                
           end case;
    end process next_state;

end rtl;