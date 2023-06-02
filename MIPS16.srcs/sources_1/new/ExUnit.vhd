library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.ALL;

entity ExUnit is
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
end ExUnit;

architecture Behavioral of ExUnit is
signal rezultat: std_logic_vector (15 downto 0); 
signal ALUb : std_logic_vector (15 downto 0);
signal aluCTRL : std_logic_vector (2 downto 0);

begin 

--mux intrare in ALU
    process(ALUSrc, RD2 , ExtImm)
    begin
        if ALUSrc   = '1' then 
            ALUb <= ExtImm;
        else
            ALUb <=RD2;
        end if;
    end process;	
    
--ALU control verificam dupa opcode
    process(AluOp, func)
        begin
           case AluOp is
            when "00" => --fct de tip r
                case func is 
                    when "000"=>aluCTRL <="000"; --add
                    when "001"=>aluCTRL <="001"; --sub
                    when "010"=>aluCTRL <="010"; --sll
                    when "011"=>aluCTRL <="011"; --srl
                    when "100"=>aluCTRL <="100"; --and
                    when "101"=>aluCTRL <="101"; --or
                    when "110"=>aluCTRL <="110"; --xor
                    when "111"=>aluCTRL <="111"; --sra
                    when others =>aluCTRL <=(others => '0');
                 end case;
            when "01" =>aluCTRL <="000"; -- +
            when "10" =>aluCTRL <="001"; -- - 
            when others => aluCTRL <= (others => '0');
          
           end case;
      end process;
      
      process(aluCTRL, RD1, ALUb, sa)
        begin
            case aluCTRL is 
            when "000" => rezultat<= RD1 + ALUb;
            when "001" => rezultat<= RD1 - ALUb;
            when "010" =>--sll
                case sa is 
                    when '1' => rezultat <= ALUb(14 downto 0) & "0";
                    when '0' => rezultat <= ALUb;
                    when others => rezultat <= (others => '0');
                 end case;  
            when "011" => --srl
                 case sa is 
                    when '1' => rezultat <= "0" & ALUb(15 downto 1);
                    when '0' => rezultat <= ALUb;
                    when others => rezultat <= (others => '0');
                 end case;  
            when "100" => rezultat <= ALUb and RD1;
            when "101" => rezultat <= ALUb or RD1; 
            when "110" => rezultat <= ALUb xor RD1; 
            when "111" => 
                case sa is
                    when '1' => rezultat <= ALUb(15) & ALUb(15 downto 1);
                    when others => rezultat <=ALUb ;
                end case;
     
            when others  => rezultat<=(others =>'0');
            end case;
            
            
           
     end process;
     
     zeroAlu<='1' when rezultat=X"0000" else '0';
     ALUrez <=rezultat;
     branchAddress <=PCinc + ExtImm;
      
end Behavioral;
