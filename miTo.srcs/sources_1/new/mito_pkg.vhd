----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Vitor Aspirot
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;



package mito_pkg is
                                                                                                                                                            --NOVAS
  type decoded_instruction_type is (I_LOAD, I_LOADI, I_STORE, I_ADD, I_SUB, I_AND, I_OR, I_ADDI, I_SUBI, I_MOV, I_MULI, I_JMP, I_BEQ, I_BNE, I_HALT, I_NOP, I_ADDST, I_ADDLOAD, I_SUBSTORE, I_SUBLOAD, I_LUILW, I_LIS, I_LDS, I_MULT);
  
  component data_path
	Port (
		clk                 : in  std_logic; 
        rst                 : in  std_logic;
        pc_mux              : in  std_logic; 
        pc_en               : in  std_logic;
        i_or_d              : in  std_logic;
        mem_write           : in  std_logic ; 
        ir_en               : in  std_logic;
        mdr_en              : in  std_logic;
        mem_to_reg          : in  std_logic;
        reg_dst             : in  std_logic;     
        reg_write           : in  std_logic; 
        ra_en               : in  std_logic; 
        rb_en               : in  std_logic; 
        rr_en               : in  std_logic; 
        addst_en            : in  std_logic;                    
        flag_z              : out std_logic;
        alu_op              : in  std_logic_vector (2 downto 0); 
        opcode              : out decoded_instruction_type;          
        adress              : out std_logic_vector (6 downto 0);
        saida_memoria       : in  std_logic_vector (15 downto 0);  
        entrada_memoria     : out std_logic_vector (15 downto 0)    
	);
  end component;

  component control_unit
    Port ( 
		clk                 : in  std_logic; 
        rst                 : in  std_logic;
        halt                : out std_logic;
        pc_mux              : out std_logic; 
        pc_en               : out std_logic;
        i_or_d              : out std_logic; 
        mem_write           : out std_logic; 
        ir_en               : out std_logic;
        mdr_en              : out std_logic;
        mem_to_reg          : out std_logic;
        reg_dst             : out std_logic;     
        reg_write           : out std_logic; 
        ra_en               : out std_logic; 
        rb_en               : out std_logic; 
        rr_en               : out std_logic; 
        addst_en            : out  std_logic;    
        flag_z              : in  std_logic;
        alu_op              : out std_logic_vector (2 downto 0); 
        opcode              : in  decoded_instruction_type
	);
  end component;
  
  component memory is
		port(        
        clk               : in  std_logic;
        saida_memoria     : out std_logic_vector (15 downto 0);
        entrada_memoria   : in  std_logic_vector (15 downto 0);
        escrita           : in std_logic; 
        endereco_memoria  : in  std_logic_vector (6  downto 0);
        rst               : in  std_logic);
          
  end component;

  component mito
  port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        halt : out std_logic 
  );
  end component;
  
 component testbench is
  port (
       signal clk 				: in  std_logic := '0';
       signal reset 			: in  std_logic;
       signal saida_memoria 	: in  std_logic_vector (15 downto 0);
       signal entrada_memoriao 	: out std_logic_vector (15 downto 0)
  ); 
  
  end component;   

end mito_pkg;

package body mito_pkg is
end mito_pkg;