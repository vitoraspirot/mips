----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Vitor Aspirot
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library mito;
use mito.mito_pkg.all;

entity data_path is
  Port (
    clk                 : in  std_logic; 
    rst                 : in  std_logic;
    pc_mux              : in  std_logic; -- mux, se passa o endereco do adder ou o incluido na instrucao
    pc_en               : in  std_logic;
    i_or_d              : in  std_logic; -- mux, se o endereco e' de intrucao ou dado
    mem_write           : in  std_logic;
    ir_en               : in  std_logic;
    mdr_en              : in  std_logic;
    mem_to_reg          : in  std_logic; -- mux, se o dado vem do MDR ou do R    
    reg_dst             : in  std_logic;
    reg_write           : in  std_logic; -- escrevendo no registrador, se 0 ta lendo
    ra_en               : in  std_logic; -- registrador A
    rb_en               : in  std_logic; -- registrador B
    rr_en               : in  std_logic; -- regristrado R  
    addst_en            : in  std_logic; 
    flag_z              : out std_logic;
    alu_op              : in  std_logic_vector (2 downto 0); -- opcode da ula
    opcode              : out decoded_instruction_type; -- opcode da instrucao
     
    adress              : out std_logic_vector (6 downto 0);
    saida_memoria       : in  std_logic_vector (15 downto 0);  -- memory to instruction register and/or data register
    entrada_memoria     : out std_logic_vector (15 downto 0)   -- ula_out or reg_out to memory
    
  );
end data_path;

architecture rtl of data_path is

    signal mux_pc       : std_logic_vector(6 downto 0);
    --signal pc           : std_logic_vector(6 downto 0);
    signal pc_out       : std_logic_vector(6 downto 0);
    
    --signal addr         : std_logic_vector(6 downto 0);
    --signal data_mem     : std_logic_vector(15 downto 0);
    signal mem_mdr      : std_logic_vector(15 downto 0);
    signal mem_ir       : std_logic_vector(15 downto 0);
    --signal mdr          : std_logic_vector(15 downto 0);
    signal ir           : std_logic_vector(15 downto 0);
    signal mdr_out      : std_logic_vector(15 downto 0);
    signal ir_out       : std_logic_vector(15 downto 0);
    signal ula_out      : std_logic_vector(15 downto 0);
    signal rs           : std_logic_vector(2 downto 0);
    signal rt           : std_logic_vector(2 downto 0);
    signal rd           : std_logic_vector(2 downto 0);
    signal data_reg     : std_logic_vector(15 downto 0);
    signal reg_a        : std_logic_vector(15 downto 0);
    signal reg_b        : std_logic_vector(15 downto 0);
    signal ra           : std_logic_vector(15 downto 0);
    signal rb           : std_logic_vector(15 downto 0);
    signal rr           : std_logic_vector(15 downto 0);
    signal reg_a_out    : std_logic_vector(15 downto 0);
    signal reg_b_out    : std_logic_vector(15 downto 0);
    signal reg_r_out    : std_logic_vector(15 downto 0);
    
    signal reg0           : std_logic_vector(15 downto 0);
    signal reg1           : std_logic_vector(15 downto 0);
    signal reg2           : std_logic_vector(15 downto 0);
    signal reg3           : std_logic_vector(15 downto 0);
    signal reg4           : std_logic_vector(15 downto 0);
    signal reg5           : std_logic_vector(15 downto 0);
    signal reg6           : std_logic_vector(15 downto 0);
    signal reg7           : std_logic_vector(15 downto 0);
      
    begin
    
    ----------------------------------------------------
    -- PROGRAM COUNTER PT1 ---- ------------------------
    ----------------------------------------------------
    PCR: process(clk)
    begin
        
        if(rst = '1')then
            mux_pc <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(pc_mux = '0')then
                mux_pc <= pc_out+1;
            else
                mux_pc <= ir_out(6 downto 0);
            end if;
        end if; 
    end process PCR;
    
    ----------------------------------------------------
    -- PROGRAM COUNTER PT2 -----------------------------
    ----------------------------------------------------
    PC: process(clk)
    begin
        if(rst = '1')then
            pc_out <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(pc_en = '1')then
                pc_out <= mux_pc; 
            end if;      
    end if;
    end process PC;
    
    ----------------------------------------------------
    -- MUX ENDERECO MEMORIA ----------------------------
    ----------------------------------------------------
   
    adress <= pc_out when i_or_d = '0' else
                          ir_out(6 downto 0) when i_or_d = '1';
    
    ----------------------------------------------------
    -- DADO MEMORIA ------------------------------------
    ----------------------------------------------------
                       
    entrada_memoria <= reg_r_out when mem_write = '1' and addst_en = '1' else 
                       reg_a_out when mem_write = '1';
                           
    ----------------------------------------------------
    -- MDR PT1 -----------------------------------------
    ----------------------------------------------------                   
    process(clk)
    begin
        if(rst = '1')then
            mem_mdr <= (others => '0');
        elsif (clk'event and clk = '1') then
            mem_mdr <= saida_memoria;      
        end if;
    end process;
    
    ----------------------------------------------------
    -- MDR PT2 -----------------------------------------
    ----------------------------------------------------                   
    process(clk)
    begin
        if(rst = '1')then
            mdr_out <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(mdr_en = '1')then
               mdr_out <= mem_mdr;
            end if;      
        end if;
    end process;
    
    ----------------------------------------------------
    -- IR PT1 ------------------------------------------
    ----------------------------------------------------                                   
    process(clk)
    begin
        if(rst = '1')then
            mem_ir <= (others => '0');
        elsif (clk'event and clk = '1') then
            mem_ir <= saida_memoria;      
        end if;
    end process;
    
    ----------------------------------------------------
    -- IR PT2 ------------------------------------------
    ----------------------------------------------------                   
    process(clk)
    begin
        if(rst = '1')then
            ir_out <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(ir_en = '1')then
               ir_out <= mem_ir;
            end if;      
        end if;
    end process;   

    ----------------------------------------------------
    -- DECODER  ----------------------------------------
    ----------------------------------------------------
    decoder: process(ir_out)
    begin
        rd <= "000";
        rs <= "000";
        rd <= "000";
        
        case ir_out(15 downto 13)is
            when "000"  =>  --  ADD
                opcode <= I_ADD;
                rd <= ir_out(12 downto 10);
                rs <= ir_out(9 downto 7);
                rt <= ir_out(6 downto 4);
        
            when "001"  =>  --  SUB
                opcode <= I_SUB;
                rd <= ir_out(12 downto 10);
                rs <= ir_out(9 downto 7);
                rt <= ir_out(6 downto 4);
                
            when "010"  =>  --  LOAD
                opcode <= I_LOAD;
                rd <= ir_out(12 downto 10);
                       
            when "011"  =>  --  STORE
                opcode <= I_STORE;
                rs <= ir_out(9 downto 7);
                
            when "100"  =>  --  JMP
                opcode <= I_JMP;
                       
            when "101"  =>  --  BEQ
                opcode <= I_BEQ;
                rs <= ir_out(12 downto 10);
                rt <= ir_out(9 downto 7);
            
            when "110"  =>  --  ADDST
                opcode <= I_ADDST;
                rs <= ir_out(12 downto 10);
                rt <= ir_out(9 downto 7);
                    
            when others => -- HALT
                opcode <= I_HALT;
        end case;
    end process decoder;
    

    ----------------------------------------------------
    -- RA  ---------------------------------------------
    ----------------------------------------------------                   
    process(clk)
    begin
        if(rst = '1')then
            reg_a_out <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(ra_en = '1')then
                reg_a_out <= reg_a;
            end if;  
        end if;
    end process;
    
    ----------------------------------------------------
    -- RB ---------------------------------------------
    ----------------------------------------------------                   
    process(clk)
    begin
        if(rst = '1')then
            reg_b_out <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(rb_en = '1')then
                reg_b_out <= reg_b;
            end if;  
        end if;
    end process;


    ----------------------------------------------------
    -- ULA ---------------------------------------------
    ----------------------------------------------------                   
    ula_out <= reg_a_out + reg_b_out when alu_op = "000" else
                reg_a_out - reg_b_out when alu_op = "001";
        
    ----------------------------------------------------
    -- RR ----------------------------------------------
    ---------------------------------------------------- 
    process(clk)
    begin
        if(rst = '1')then
            reg_r_out <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(rr_en = '1')then
                reg_r_out <= ula_out;
            end if;  
        end if;
    end process;
    
    flag_z <= '1' when reg_r_out = x"0000" else '0';
    
    ----------------------------------------------------
    -- MUX DADO REGISTRADOR ----------------------------
    ----------------------------------------------------
    data_reg <= reg_r_out when mem_to_reg = '0' else
                       mdr_out when mem_to_reg = '1';
    
    ----------------------------------------------------
    -- BANCO DE REGISTRADORES --------------------------
    ----------------------------------------------------
    reg_bank:process(clk)
        begin
            if(clk'event and clk = '1') then
                if(reg_write = '1') then
                    case rd is
                        when "000" => reg0 <= data_reg;
                        when "001" => reg1 <= data_reg;
                        when "010" => reg2 <= data_reg;
                        when "011" => reg3 <= data_reg;
                        when "100" => reg4 <= data_reg;
                        when "101" => reg5 <= data_reg;
                        when "110" => reg6 <= data_reg;
                        when others => reg7 <= data_reg;
                       end case;
                    else
                        if(rst = '1') then
                          reg0 <= "0000000000000000"; 
                          reg1 <= "0000000000000000"; 
                          reg2 <= "0000000000000000"; 
                          reg3 <= "0000000000000000"; 
                          reg4 <= "0000000000000000"; 
                          reg5 <= "0000000000000001";
                          reg6 <= "0000000000000010";
                          reg7 <= "0000000000000000";  
                    end if;
                end if;
            end if;
        end process; 
     define_rs:
        process(clk)
        begin
            if(clk'event and clk = '1') then
                case rs is
                    when "000"  => reg_a <= reg0;
                    when "001"  => reg_a <= reg1;
                    when "010"  => reg_a <= reg2;
                    when "011"  => reg_a <= reg3;
                    when "100"  => reg_a <= reg4;
                    when "101"  => reg_a <= reg5;
                    when "110"  => reg_a <= reg6;
                    when others => reg_a <= reg7;
                end case;
               if(rst = '1') then
                    reg_a <= x"0000"; 
               end if;
            end if;
        end process;
    define_rt:
        process(clk)
        begin
            if(clk'event and clk = '1') then
                case rt is
                    when "000"  => reg_b <= reg0;
                    when "001"  => reg_b <= reg1;
                    when "010"  => reg_b <= reg2;
                    when "011"  => reg_b <= reg3;
                    when "100"  => reg_b <= reg4;
                    when "101"  => reg_b <= reg5;
                    when "110"  => reg_b <= reg6;
                    when others => reg_b <= reg7;
                end case;  
                if(rst = '1') then
                    reg_b <= x"0000"; 
               end if;          
            end if;
        end process; 
     
end rtl;
