library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity MainControl is
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
           
end MainControl;

architecture Behavioral of MainControl is
begin
    process(instr)
    begin
        BGEZ<='0';
        BLTZ<='0';
        RegDest<='0';
        ExtOp<='0';
        ALUSrc<='0';
        Branch<='0';
        Jump<='0';
        ALUOp<="00";
        MemToReg<='0';
        MemToWrite<='0';
        RegWrite<='0';
        case(instr) is
        when "000" =>  --instr R
            RegDest<='1';
            RegWrite<='1';
            ALUOp<="00";
        when "001" =>  --ADDI
            ExtOp<='1';
            ALUSrc<='1';
            RegWrite<='1';
            ALUOp<="01";
        when "010" => --LW
            ExtOp<='1';
            ALUSrc<='1';
            MemToReg<='1';
            RegWrite<='1';
            ALUOp<="01";
        when "011" =>  --SW
            ExtOp<='1';
            ALUSrc<='1';
            MemToWrite<='1';
            --MemToReg<='1'; --
            ALUOp<="01";
        
        when "100" =>  --BGEZ
            ExtOp <='1';
            BGEZ<='1';
            ALUOp <="10"; 
        when "101" => --BLTZ
            ExtOp <='1';
            BLTZ <='1';
            ALUOp <="10";
        when "110" => --J 
            Jump<='1';
        when "111" => --BEQ
            Branch<='1';
            ExtOp <='1';
            ALUOp <="10";
        when others =>
            BGEZ<='0';
            BLTZ<='0';
            RegDest<='0';
            ExtOp<='0';
            ALUSrc<='0';
            Branch<='0';
            Jump<='0';
            ALUOp<="00";
            MemToReg<='0';
            MemToWrite<='0';
            RegWrite<='0';
        end case;
    end process;
end Behavioral;
