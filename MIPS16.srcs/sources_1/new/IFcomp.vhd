library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (clk: in std_logic ;
          rst : in std_logic;
          en : in std_logic;
          branchAddress : in std_logic_vector(15 downto 0);
          jumpAddress : in std_logic_vector(15 downto 0);
          Jump : in std_logic;
          PCSrc : in std_logic;
          instruction : out std_logic_vector(15 downto 0);
          PCinc : out std_logic_vector(15 downto 0));
end IFetch;

architecture Behavioral of IFetch is

signal PC : std_logic_vector(15 downto 0) := (others => '0');
signal PCAuxInc, nextAdr, muxBranchAdr: std_logic_vector(15 downto 0);

-- Memorie ROM
type tROM is array (0 to 31) of std_logic_vector (15 downto 0);
signal ROM : tROM := (

    -- Acest program calculeaza suma maxima dintre k submultimi ale unui vector. 
    -- Cursorul se retine  in registrul $1. Acesta are rolul de a verifica cate
    -- elemente sunt intr-o submultime.
    -- Suma curenta este retinuta in registrul 2 si calculeaza suma pentru fiecare subvector.
    -- Luam din memorie n, numarul de elemente din vector si il retinem in registrul $5
    -- La fel facem si cu i,k
    -- Dupa aceea in bucla while calculam suma maxima dintre cele k parti iar rezultatul final este pus in  registrul 4,
    
    
    B"001_000_001_0000000",  -- 00:  addi $1, $0, 0	    x”2080”		# cursor
    B"001_000_010_0000000",  -- 01: addi $2, $0, 0      x”2100”     # sCurenta
    B"010_000_101_0000000",  -- 02: lw $5, 0($0)        x”4280”		# n
    B"001_000_110_0000001",  --  03: addi $6, $0, 1     x”2301”		# i
    B"010_000_111_0001101",  --  04: lw $7, 13($0)      x”438d”		# k
    B"111_001_111_0000100",  --  05: beq $1, $7, 04	    x”e784”	    # Check if cursor is less than k
    B"001_001_001_0000001",  --  06: addi $1, $1, 1     x”2481”	    # increment cursor
    B"010_110_100_0000000",  --  07: lw $4, 0($6)       x”5a00”     # load v[i]
    B"000_010_100_010_0_000",  --  08: add $2, $2, $4    x”0a20”     # add v[i] to sCurenta
    B"110_0000000001100",  --  09: j 12                 x”c00c”
    B"001_000_001_0000001",  --  10:	addi $1, $0, 1  x”2081”     # cursor = 1
    B"010_110_010_0000000",  --  11: lw $2, 0($6)       x”5900”     # sCurenta = v[i]
    B"010_000_100_0001110",  --  12: lw $4 14($0)		x”420e”	    # Check for new maxv
    B"000_010_100_011_0_001",  --  13: sub $3, $2, $4   x”0a31”
    B"101_011_000_0000001",  --  14: bltz $3, 1         x"AC01"
    B"011_000_010_0001110",  --  15: sw $2, 14($0)		x"610E"	        # Update maxv
    B"001_110_110_0000001",  --  16: addi $6, $6, 1 	x"3B01"		    # Increment i
    B"000_110_101_100_0_001",  --  17: sub $4, $6, $5   x"1AC1"
    B"101_100_000_1110010",  --  18: bltz $4, -14 		x"B072"	        # Check if i is less than n
    B"010_000_100_0001110",  --  19: lw $4, 14($0)   	x"420E"	        # vuzualizare rez pe write data
    others => X"0000");
begin
    -- Program Counter
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                PC <= (others => '0');
            elsif en = '1' then
                PC <= nextadr;
            end if;
        end if;
    end process;

    -- Instruction OUT

    instruction <= ROM(conv_integer(PC(7 downto 0)));
    -- PC incremented
     PCAuxInc <= PC + 1;
    PCinc <= PCAuxInc; 
   process(PCSrc, Jump, PCAuxInc, branchAddress, jumpAddress)
   begin
    if Jump ='1' then 
        nextAdr<=jumpAddress;
    elsif PCSrc ='1' then
        nextAdr<=branchAddress;
    else
        nextAdr<= PCAuxInc;
    end if;
   end process;
end Behavioral;