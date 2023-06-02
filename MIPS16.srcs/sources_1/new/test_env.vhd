library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component ;

component SSD is
    Port ( clk: in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR(15 downto 0);
           an: out STD_LOGIC_VECTOR(3 downto 0);
           cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch is
    Port (clk: in STD_LOGIC;
          rst : in STD_LOGIC;
          en : in STD_LOGIC;
          branchAddress : in STD_LOGIC_VECTOR(15 downto 0);
          jumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
          Jump : in STD_LOGIC;
          PCSrc : in STD_LOGIC;
          instruction : out STD_LOGIC_VECTOR(15 downto 0);
          PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end component; 

component IDecode is
Port ( clk: in std_logic;
           en : in std_logic;    
           RegWrite : in std_logic;
           instr : in std_logic_vector(15 downto 0); --md
           RegDst : in std_logic;
           WD : in std_logic_vector(15 downto 0);
           ExtOp : in std_logic;
           RD1 : out std_logic_vector(15 downto 0);
           RD2 : out std_logic_vector(15 downto 0);
           ExtImm : out std_logic_vector(15 downto 0);
           func : out std_logic_vector(2 downto 0);
           sa : out std_logic);
end component;

component MainControl is
Port ( instr: in std_logic_vector(2 downto 0); 
           BGEZ: out std_logic;
           BLTZ: out std_logic;
           RegDest: out std_logic;
           ExtOp: out std_logic;
           ALUSrc: out std_logic;
           Branch: out std_logic;
           Jump: out std_logic;
           ALUOp: out std_logic_vector(1 downto 0);
           MemToWrite: out std_logic;
           MemToReg: out std_logic;
           RegWrite: out std_logic);
end component ;

component ExUnit is
 Port (RD1: in std_logic_vector (15 downto 0);
           RD2: in std_logic_vector (15 downto 0);
           ALUSrc: in std_logic;
           ExtImm: in std_logic_vector (15 downto 0);
           sa: in std_logic ;
           func: in std_logic_vector (2 downto 0);
           AluOp: in std_logic_vector (1 downto 0); 
           PCinc: in std_logic_vector (15 downto 0);
           ALUrez: out std_logic_vector (15 downto 0);
           branchAddress: out std_logic_vector (15 downto 0);
           zeroAlu:out std_logic);
end component ;

component MEM is
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component;
-- fetch
signal instructions, PCinc, jumpAdr, branchAdr: std_logic_vector (15 downto 0);
--
--decode
signal RD1, RD2,WD, ExImm:std_logic_vector (15 downto 0);
signal func: std_logic_vector (2 downto 0);
signal sa: std_logic ;
--
--ExUnit
signal zero, PcSrc, ALURezBit, beq,bgezOut, bltzOut:std_logic ;
signal ALURez: std_logic_vector(15 downto 0) ;
signal ALURez1: std_logic_vector(15 downto 0) ;

--
--MEM
 signal MemData: std_logic_vector (15 downto 0);
--
--semnale main 
signal bgez, bltz, RegDest, ExOp, ALUSrc, branch, jump, MemToWrite, MemToReg, RegWrite: std_logic ;
signal ALUOp : std_logic_vector (1 downto 0); 
--
-- branchuri
signal rezPcSrc, rezBgez, rezBltz, rezBranch: std_logic ;
--

signal en , rst: std_logic;
signal digits : STD_LOGIC_VECTOR(15 downto 0);
begin 
 -- initializare butoane rst, en 
    debouncerEn: MPG port map(en, btn(0), clk);
    debouncerRst: MPG port map(rst, btn(1), clk);
 --
    ifFetch: IFetch port map(clk, rst, en, branchAdr, jumpAdr ,jump  ,PcSrc ,instructions ,PCinc);
    idDecode: IDecode port map(clk, en, RegWrite, instructions , RegDest, WD , ExOp , RD1 ,RD2, ExImm , func , sa);
    iMainControl: MainControl port map( instructions(15 downto 13), bgez , bltz, RegDest , ExOp , ALUSrc , branch , jump , ALUOp , MemToWrite, MemToReg , RegWrite );
    iExUnit: ExUnit port map ( RD1 , RD2 , ALUSrc , ExImm ,sa, func, ALUOp , PCinc , ALURez , branchAdr, zero);
    iMEM: MEM port map( clk, en, ALURez , RD2, MemToWrite , MemData , ALURez1 );
 

    -- WriteBack
    with MemToReg select
        WD <= MemData when '1',
              ALURez when '0',
              (others => '0') when others;
              
    --branchuri       
    ALURezBit<=ALURez(15);
    rezBgez <= ((not ALURezBit )or zero)and bgez;
    rezBltz <= ((not zero ) and ALURezBit ) and bltz;
    rezBranch <= branch and zero; 
    rezPcSrc <= rezBgez or rezBltz or rezBranch ;
    PcSrc <= rezPcSrc;
    
    jumpAdr<=PCinc(15 downto 13) & instructions(12 downto 0);
    
    
    display: SSD port map(clk, digits, an, cat);
    process( sw, instructions , PCinc , RD1 ,RD2 , ExImm , ALURez , MemData , WD)
        begin
        case sw(7 downto 5) is
            when "000"=> digits <= instructions ;
            when "001"=> digits <= PCinc  ;
            when "010"=> digits <= RD1  ;
            when "011"=> digits <= RD2 ;
            when "100"=> digits <= ExImm  ;
            when "101"=> digits <= ALURez  ;
            when "110"=> digits <= MemData  ;
            when "111"=> digits <= WD ;
            when others => digits <= (others => 'X');
        end case; 
    end process;
    led(11 downto 0) <=ALUOp & RegDest & ExOp & ALUSrc & branch & bgez & bltz & jump & MemToWrite & MemToReg & RegWrite;
end Behavioral;
