----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/29/2024 05:12:33 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
signal s: std_logic_vector(31 downto 0):=(others=>'0');--il folosesc ca sa afisez ceva pe ssd

signal jump: STD_LOGIC;
signal RegWr: STD_LOGIC;
signal ExtOp: STD_LOGIC;
signal RegDst: STD_LOGIC;
signal ALUSrc: STD_LOGIC;
signal ALUOp: std_logic_vector(2 downto 0):=(others=>'0');
signal switch: std_logic_vector(2 downto 0):=(others=>'0');
signal MemtoReg: STD_LOGIC;
signal MemWrite: STD_LOGIC;
signal RD1: std_logic_vector(31 downto 0):=(others=>'0');
signal func_ext: std_logic_vector(31 downto 0):=(others=>'0');
signal sa_ext: std_logic_vector(31 downto 0):=(others=>'0');
signal RD2: std_logic_vector(31 downto 0):=(others=>'0');
signal WD: std_logic_vector(31 downto 0):=(others=>'0');
signal sa: std_logic_vector(4 downto 0):=(others=>'0');
signal func: std_logic_vector(5 downto 0):=(others=>'0');
signal ext_imm: std_logic_vector(31 downto 0):=(others=>'0');
signal branch: STD_LOGIC;
signal branch_not: STD_LOGIC;
signal rst: STD_LOGIC;--pt buton mpg

            
    signal    pcSrc:  STD_LOGIC;
    signal    zero:  STD_LOGIC;
    signal    not_zero:  STD_LOGIC;
     signal    instruction:  std_logic_vector(31 downto 0);
      signal   pcPLus4:  std_logic_vector(31 downto 0);
     signal   jumpAdress:  std_logic_vector(31 downto 0);
     signal  branchAdress:  std_logic_vector(31 downto 0);
     signal  ALURes:  std_logic_vector(31 downto 0);
     signal  ALUResout:  std_logic_vector(31 downto 0);
     signal  MemData:  std_logic_vector(31 downto 0);

component IFetch is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);               
           jump: in STD_LOGIC;
            pcSrc: in STD_LOGIC;
            instruction: out std_logic_vector(31 downto 0);
            pc4: out std_logic_vector(31 downto 0);
            jumpAdress: in std_logic_vector(31 downto 0);
            branchAdress: in std_logic_vector(31 downto 0)
           );
 end component;
 
 component UnitateControl is
    Port (  
            instr : in STD_LOGIC_VECTOR (5 downto 0);
                    
            RegDst: out STD_LOGIC;
            ExtOp: out STD_LOGIC;
            ALUSrc: out STD_LOGIC;
            Branch: out STD_LOGIC;
            BranchNot: out STD_LOGIC;
            Jump: out STD_LOGIC;
            ALUOp: out STD_LOGIC_vector(2 downto 0);
            MemtoReg: out STD_LOGIC;
            MemWrite: out STD_LOGIC;
            RegWrite: out STD_LOGIC
        );
 end component;
 
 component InstrDecode is
   Port (   clk : in STD_LOGIC;
            instr : in STD_LOGIC_VECTOR (25 downto 0);        
            RegWrite: in STD_LOGIC;
            en: in STD_LOGIC;
            RegDst: in STD_LOGIC;
             ExtOp: in std_logic;
             WD: in std_logic_vector(31 downto 0);
             RD1: out std_logic_vector(31 downto 0);
             RD2: out std_logic_vector(31 downto 0);
             EXT_IMM:out std_logic_vector(31 downto 0);
             func:out std_logic_vector(5 downto 0);
             sa:out std_logic_vector(4 downto 0)
              );
 end component;
 
 component ALU is
   Port (  
           ALUSrc : in STD_LOGIC;
              RD1 : in STD_LOGIC_VECTOR (31 downto 0);        
              RD2 : in STD_LOGIC_VECTOR (31 downto 0);        
              Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);        
              sa : in STD_LOGIC_VECTOR (4 downto 0);        
              func : in STD_LOGIC_VECTOR (5 downto 0);        
              ALUOp : in STD_LOGIC_VECTOR (2 downto 0);        
              PcPlus4 : in STD_LOGIC_VECTOR (31 downto 0);                    
              ALURes : out STD_LOGIC_VECTOR (31 downto 0);                    
              BranchAdress : out STD_LOGIC_VECTOR (31 downto 0);                    
              Zero : out STD_LOGIC;                    
              NotZero : out STD_LOGIC                    
    );
 end component;
 
 component ram_wr_1st is
     Port ( clk : in STD_LOGIC;
            MemWrite : in STD_LOGIC;
            En : in STD_LOGIC;--buton
            ALUResin : in STD_LOGIC_VECTOR (31 downto 0);
            WriteData : in STD_LOGIC_VECTOR (31 downto 0);
            ReadData : out STD_LOGIC_VECTOR (31 downto 0);
            ALUResout : out STD_LOGIC_VECTOR (31 downto 0));
 end component;

begin
jumpAdress<=pcPlus4(31 downto 28)&instruction(25 downto 0)& "00";
pcSrc<=(branch and zero) or (branch_not and not_zero);
instructionFetch:IFetch port map
(
    clk=>clk,
    btn=>btn,
    rst=>rst,
    jump=>jump,
      pcSrc=>    pcSrc,
      instruction=>    instruction,
       pc4=>   pcPLus4,
       jumpAdress=>   jumpAdress,
       branchAdress=>   branchAdress
);
button:entity WORK.mpg port map
(
btn=>btn(0),
clk=>clk,
en=>rst
);
display:entity WORK.ssd port map
(
   clk=>clk,
   cat=>cat,
   an=>an,
   data=>s
);

UC:UnitateControl port map
(
    instr =>instruction(31 downto 26),
                    
            RegDst=>RegDst,
            ExtOp=>ExtOp,
            ALUSrc=>ALUSrc,
            Branch=>branch,
            BranchNot=>branch_not,
            Jump=>jump,
            ALUOp=>ALUOp,
            MemtoReg=>MemtoReg,
            MemWrite=>MemWrite,
            RegWrite=>RegWr
    
);

ID:InstrDecode port map
(
    clk =>clk,
            instr =>instruction(25 downto 0),        
            RegWrite=>RegWr,
            en=>rst,
            RegDst=>RegDst,
             ExtOp=>ExtOp,
             WD=>WD,
             RD1=>RD1,
             RD2=>RD2,
             EXT_IMM=>ext_imm,
             func=>func,
             sa=>sa
);

EX:ALU port map
(
       ALUSrc =>ALUSrc,
         RD1 =>RD1,        
         RD2 =>RD2,       
          Ext_Imm =>ext_imm,        
          sa =>sa,        
          func =>func,        
          ALUOp =>ALUOp,        
         PcPlus4 =>pcPlus4,                    
          ALURes =>ALURes,                    
          BranchAdress =>branchAdress,                    
          Zero =>zero,                    
           NotZero =>not_zero
);
MEM:ram_wr_1st port map
(
           clk =>clk,
            MemWrite =>MemWrite,
            En =>rst,--buton
            ALUResin =>ALURes,
            WriteData =>RD2,
            ReadData =>MemData,
            ALUResout =>ALUResout
);

process(MemtoReg)
begin
     if(MemtoReg='1') then 
        WD<=MemData;
     else
         WD<=ALUresout;
     end if;   
end process;



led(11 downto 0)<=ALUOp & RegDst & ExtOp & ALUSrc & branch & branch_not & jump & MemWrite & MemtoReg & RegWr;

switch<=sw(7 downto 5);

process(switch)
begin
case switch is
    when "000" => s<=instruction;
    when "001" => s<=pcPlus4;
    when "010" => s<=RD1;
    when "011" => s<=RD2;
    when "100" => s<=ext_imm;
    when "101" => s<=ALUResout;
    when "110" => s<=MemData;
    when others => s<=WD;
    
  end case;

end process;

end Behavioral;
