----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Vitor Aspirot
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library mito;
use mito.mito_pkg.all;

entity miTo is
  Port (
      rst                    : in  std_logic;
      clk                    : in  std_logic;
      halt                   : out  std_logic      
   );
end miTo;

architecture rtl of miTo is

    signal pc_mux_s              :  std_logic; 
    signal pc_en_s               :  std_logic;
    signal i_or_d_s              :  std_logic; 
    signal ir_en_s               :  std_logic;
    signal mdr_en_s              :  std_logic;
    signal mem_to_reg_s          :  std_logic;
    signal reg_dst_s             :  std_logic;     
    signal reg_write_s           :  std_logic; 
    signal ra_en_s               :  std_logic; 
    signal rb_en_s               :  std_logic; 
    signal rr_en_s               :  std_logic;
    signal addst_en_s            :  std_logic;     
    signal flag_z_s              :  std_logic;
    signal alu_op_s              :  std_logic_vector (2 downto 0); 
    signal opcode_s              :  decoded_instruction_type; 
    signal adress_s              :  std_logic_vector (6 downto 0);
    signal saida_memoria_s       :  std_logic_vector (15 downto 0);  
    signal entrada_memoria_s     :  std_logic_vector (15 downto 0);
    signal mem_write_s           :  std_logic;

begin

control_unit_i : control_unit
    port map( 
    clk                 => clk,
    rst                 => rst,
    halt                => halt,
    pc_mux              => pc_mux_s,
    pc_en               => pc_en_s,
    i_or_d              => i_or_d_s,
    mem_write           => mem_write_s,
    ir_en               => ir_en_s,
    mdr_en              => mdr_en_s,
    mem_to_reg          => mem_to_reg_s,
    reg_dst             => reg_dst_s,    
    reg_write           => reg_write_s,
    ra_en               => ra_en_s,
    rb_en               => rb_en_s,
    rr_en               => rr_en_s,
    addst_en            => addst_en_s,    
    flag_z              => flag_z_s,
    alu_op              => alu_op_s,
    opcode              => opcode_s
    );

data_path_i : data_path
  port map (
    clk                 => clk,
    rst                 => rst,
    pc_mux              => pc_mux_s,
    pc_en               => pc_en_s,
    i_or_d              => i_or_d_s,
    mem_write           => mem_write_s,
    ir_en               => ir_en_s,
    mdr_en              => mdr_en_s,
    mem_to_reg          => mem_to_reg_s,
    reg_dst             => reg_dst_s,   
    reg_write           => reg_write_s,
    ra_en               => ra_en_s,
    rb_en               => rb_en_s,
    rr_en               => rr_en_s,
    addst_en            => addst_en_s,   
    flag_z              => flag_z_s,
    alu_op              => alu_op_s,
    opcode              => opcode_s,    
    adress              => adress_s,
    saida_memoria       => saida_memoria_s,
    entrada_memoria     => entrada_memoria_s
  );
  
memory_i : memory
  port map(
    clk                 => clk,
    rst                 => rst,    
    endereco_memoria    => adress_s,
    escrita             => mem_write_s,
    saida_memoria       => saida_memoria_s,
    entrada_memoria     => entrada_memoria_s
  );
 
end rtl;
