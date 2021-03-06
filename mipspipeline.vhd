library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity mipspipeline is
	port (
	-- Entradas --
	clk : in std_logic;
	-- Saidas para testar funcionamento do programa --
	Muxpc_out : out std_logic_Vector(31 downto 0);
	MEMI_out : out std_logic_Vector(31 downto 0);
	BREGrs_out : out std_logic_Vector(31 downto 0);
	BREGrt_out : out std_logic_Vector(31 downto 0);
	WB_out : out std_logic_Vector(2 downto 0);
	EXE_out : out std_logic_Vector(7 downto 0);
	MEM_out : out std_logic_Vector(1 downto 0);
	ULA_out : out std_logic_Vector(31 downto 0);
	MUXindice_out : out std_logic_Vector(4 downto 0);
	MEMD_out : out std_logic_Vector(31 downto 0);
	MUXdado_out : out std_logic_Vector(31 downto 0);
	mux1_out: out std_logic_Vector(31 downto 0);
	mux2_out: out std_logic_Vector(31 downto 0);
	PCendwb : out std_logic_vector(31 downto 0);
	muxS0 : out std_logic;
	muxS1 : out std_logic;
	-- Saidas da implementaÃƒÂ§ÃƒÂ£o no FPGA -----------
	saida_conversor0 : out std_logic_vector(0 to 6);
	saida_conversor1 : out std_logic_vector(0 to 6);
	saida_conversor2 : out std_logic_vector(0 to 6);
	saida_conversor3 : out std_logic_vector(0 to 6);
	saida_conversor4 : out std_logic_vector(0 to 6);
	saida_conversor5 : out std_logic_vector(0 to 6);
	saida_conversor6 : out std_logic_vector(0 to 6);
	saida_conversor7 : out std_logic_vector(0 to 6);
	-- Chaves seletoras FPGA --------------------
	sel_saida_chaves : in std_logic_vector(1 downto 0)
	);
end entity;

architecture mipspipeline_arch of mipspipeline is
component regifid is
	generic (WSIZE : natural := 32);
	port (
		clk: in std_logic;
		PC4_in : in std_logic_vector(WSIZE-1 downto 0);
		instruction_in : in std_logic_vector(WSIZE-1 downto 0);
		pc4_out : out std_logic_vector(WSIZE-1 downto 0);
		instruction_out :out std_logic_vector(WSIZE-1 downto 0));
end component;

--------------------- Conversor para implementaÃƒÂ§ÃƒÂ£o no FPGA --------
component conversor7seg is
	port(data : in STD_LOGIC_VECTOR(3 DOWNTO 0);
			Z : out STD_LOGIC_VECTOR(0 TO 6));
end component;
-------------------- Componentes principais ----------------------
component regidex is
	generic (WSIZE : natural := 32);
	port (
    -- entradas --
		clk: in std_logic;
    control_wb_in : in std_logic_vector(2 downto 0);
    control_mem_in : in std_logic_vector(1 downto 0);
    control_exec_in : in std_logic_vector(7 downto 0);
    PC4_in : in std_logic_vector(WSIZE-1 downto 0);
    read_data1_in : in std_logic_vector(WSIZE-1 downto 0);
    read_data2_in : in std_logic_vector(WSIZE-1 downto 0);
    sign_ext_imm_in : in std_logic_vector(WSIZE-1 downto 0);
    shamnt_in : in std_logic_vector(4 downto 0);
    reg_rt_in : in std_logic_vector(4 downto 0);
    reg_rd_in : in std_logic_vector(4 downto 0);
		beq_in : in std_logic;
		bne_in : in std_logic;
    -- saidas --
    control_wb_out : out std_logic_vector(2 downto 0);
    control_mem_out : out std_logic_vector(1 downto 0);
    reg_dst_out: out std_logic_vector(1 downto 0);
    aluOP_out: out std_logic_vector(3 downto 0);
    aluSRC1_out: out std_logic;
    aluSRC2_out: out std_logic;
    PC4_out : out std_logic_vector(WSIZE-1 downto 0);
    read_data1_out : out std_logic_vector(WSIZE-1 downto 0);
    read_data2_out : out std_logic_vector(WSIZE-1 downto 0);
    sign_ext_imm_out : out std_logic_vector(WSIZE-1 downto 0);
    shamnt_out : out std_logic_vector(4 downto 0);
    reg_rt_out : out std_logic_vector(4 downto 0);
    reg_rd_out : out std_logic_vector(4 downto 0);
	 beq_out : out std_logic;
    bne_out : out std_logic);
end component;

component regexmem is
	generic (WSIZE : natural := 32);
	port (
    -- entradas --
    clk: in std_logic;
    control_wb_in : in std_logic_vector(2 downto 0);
    control_mem_in : in std_logic_vector(1 downto 0);
    PC4_shift_in : in std_logic_vector(WSIZE-1 downto 0);
    ula_result_in : in std_logic_vector(WSIZE-1 downto 0);
    writa_data_in : in std_logic_vector(WSIZE-1 downto 0);
    write_reg_dst_in : in std_logic_vector(4 downto 0);
    -- saidas --
    control_wb_out : out std_logic_vector(2 downto 0);
    PC4_shift_out : out std_logic_vector(WSIZE-1 downto 0);
    mem_read_out : out std_logic;
    mem_write_out : out std_logic;
    adress_out : out std_logic_vector(WSIZE-1 downto 0);
    write_data_out : out std_logic_vector(WSIZE-1 downto 0);
    write_reg_dst_out : out std_logic_vector(4 downto 0));
end component;

component regmemwb is
	generic (WSIZE : natural := 32);
	port (
		clk : in std_logic;
		-- entradas --
		control_wb_in : in std_logic_vector (2 downto 0);
		read_data_in : in std_logic_vector (31 downto 0);
		resul_ula_in : in std_logic_vector (31 downto 0);
		write_register_in : in std_logic_vector(4 downto 0);
		PC4_shift_in : in std_logic_vector(31 downto 0);
		-- saidas --
		reg_write_out : out std_logic;
		mem_to_reg_out : out std_logic_vector(1 downto 0);
		write_data_breg_out : out std_logic_vector(31 downto 0);
		data_ula_out : out std_logic_vector(31 downto 0);
		reg_dst_out : out std_logic_vector(4 downto 0);
		PC4_shift_out : out std_logic_vector(31 downto 0));
end component;

---------------------- Multiplexadores --------------------
component mux2 is
	port (
		Sel : in std_logic;
		A : in std_logic_Vector(31 downto 0);
		B : in std_logic_Vector(31 downto 0);
		Z : out std_logic_Vector(31 downto 0));
end component;

component mux4 is
	port (
		Sel : in std_logic_Vector(1 downto 0);
		A : in std_logic_Vector(31 downto 0);
		B : in std_logic_Vector(31 downto 0);
		C : in std_logic_Vector(31 downto 0);
		D : in std_logic_Vector(31 downto 0);
		Z : out std_logic_Vector(31 downto 0));
end component;

component controle is
	port (
			opCode: in std_logic_vector(5 downto 0);
			Funct : in std_logic_vector(5 downto 0);
			WB : out std_logic_vector (2 downto 0);
			MEM : out std_logic_vector(1 downto 0);
			EXE : out std_logic_vector(7 downto 0);
			jumps, jr, beq, bne : out std_logic
		);
end component;

component PC is
	port (
		clk : in std_logic;
		PC_in : in std_logic_vector(31 downto 0);
		PC_out : out std_logic_vector(31 downto 0) := (others => '0'));
end component;

component breg is
generic (WSIZE : natural := 32);
port (
	clk, wren : in std_logic;
	radd1, radd2, wadd : in std_logic_vector(4 downto 0);
	wdata : in std_logic_vector(WSIZE-1 downto 0);
	r1, r2 : out std_logic_vector(WSIZE-1 downto 0));
end component;

component ula is
	generic (WSIZE : natural := 32);
	port (
		opcode		: in std_logic_vector(3 downto 0);
		A, B			: in std_logic_vector(WSIZE-1 downto 0);
		Z				: out std_logic_vector(WSIZE-1 downto 0);
		zero, ovfl	: out std_logic);
end component;

component meminst IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component memdados IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component somador is
	port (	a : in std_logic_vector(31 downto 0);
					b : in std_logic_vector(31 downto 0);
					result : out std_logic_vector (31 downto 0)
	);
end component;

component comparador is
	port (	a : in std_logic_vector(31 downto 0);
			b : in std_logic_vector(31 downto 0);
			result : out std_logic
		);
end component;

-- architecture mipspipeline_arch of mipspipeline is

signal clk_s : std_logic := '0';

----------------------- DECLARAÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢O DOS SIGNALS --------------------
-----------------------          IF            --------------------
signal sel_mux_pc : std_logic_vector(1 downto 0) := (others => '0'); 				-- ENTRADA SELETORA MUX 4 DO PC
signal mux_pc_out : std_logic_vector(31 downto 0) := (others => '0');				-- SAIDA  MUX 4 DO PC
signal pc_init : std_logic_vector(31 downto 0) := (others => '0');					-- SAIDA  PC
signal pc4 : std_logic_vector(31 downto 0) := (others => '0');					-- SAIDA SOMADOR PC + 4
signal mem_inst_out : std_logic_vector(31 downto 0) := (others => '0');			-- SAIDA MEM INSTRUÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ES
-----------------------          ID            --------------------
signal instrucao : std_logic_vector(31 downto 0) := (others => '0'); 	-- SAIDA IF/ID INSTRUÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ES
signal jump_mux_out : std_logic_vector(31 downto 0) := (others => '0'); 			-- SAIDA RS DO BREG | ENTRADA DO MUX 4 DO PC
signal reg_rs : std_logic_vector(31 downto 0) := (others => '0'); 		-- SAIDA RS DO BREG | ENTRADA DO REG ID/EX
signal reg_rt : std_logic_vector(31 downto 0) := (others => '0'); 		-- SAIDA RT DO BREG | ENTRADA DO REG ID/EX
signal id_pc4 : std_logic_vector(31 downto 0) := (others => '0');			-- SAIDA PC+4 DO REG IF/ID | ENTRADA DO REG ID/EX
signal kte_shift : std_logic_vector(31 downto 0) := (others => '0'); 		-- SAIDA SHAMNT DO REG IF/ID | ENTRADA DO REG ID/EX
signal or_rd : std_logic := '0';														-- SAIDA OERAÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢O OR do RT | ENTRADA DO jalr
signal control_wb : std_logic_Vector(2 downto 0) := (others => '0'); 			-- SAIDA WB DO CONTROLE 3 bits
signal control_mem : std_logic_Vector(1 downto 0) := (others => '0'); 	-- SAIDA MEM DO CONTROLE 2 bits
signal control_exe : std_logic_Vector(7 downto 0) := (others => '0'); 	-- SAIDA EXECUTE DO CONTROLE 9 bits
signal control_beq : std_logic := '0'; 											-- SAIDA BEQ DO CONTROLE
signal control_bne : std_logic := '0'; 											-- SAIDA BNE DO CONTROLE
signal control_j : std_logic := '0'; 												-- SAIDA JUMP DO CONTROLE
signal control_jr : std_logic := '0'; 											-- SAIDA JR DO CONTROLE
signal comp : std_logic := '0'; 														-- Sinal do comparador, para o BEQ e BNE
signal saida_mux2 : std_logic_vector(31 downto 0) := (others => '0'); 	-- SAIDA JALR DO MUX
-----------------------          EXECUTE        ---------------------
signal pipe_wb : std_logic_Vector(2 downto 0) := (others => '0'); 				-- SAIDA WB DO ID/EX 3 bits
signal pipe_mem : std_logic_Vector(1 downto 0) := (others => '0'); 			-- SAIDA MEM DO ID/EX  2 bits
signal pipe_exe : std_logic_Vector(7 downto 0) := (others => '0'); 			-- SAIDA EXE DO ID/EX  9 bits
signal pipe_beq : std_logic := '0'; 												-- SAIDA BEQ DO ID/EX
signal pipe_bne : std_logic := '0'; 												-- SAIDA BNE DO ID/EX
signal pipe_pc4 : std_logic_Vector(31 downto 0) := (others => '0'); 		-- SAIDA PC+4 DO ID/EX
signal pipe_kte : std_logic_Vector(31 downto 0) := (others => '0'); 		-- SAIDA KTE SE DO ID/EX
signal shift_kte : std_logic_Vector(31 downto 0) := (others => '0'); 		-- SAIDA KTE DO SL2
signal shamnt_32 : std_logic_Vector(31 downto 0) := (others => '0');
signal saida_mux4_32 : std_logic_Vector(31 downto 0) := (others => '0');
signal pipe_rs : std_logic_Vector(31 downto 0) := (others => '0'); 			-- SAIDA RS DO ID/EX
signal pipe_rt : std_logic_Vector(31 downto 0) := (others => '0'); 			-- SAIDA RT DO ID/EX
signal pipe_shamt : std_logic_Vector(4 downto 0) := (others => '0'); 		-- SAIDA SHAMNT DO ID/EX
signal pipe_rt_ind : std_logic_Vector(31 downto 0) := (others => '0'); 	-- SAIDA INDICE RT DO ID/EX
signal pipe_rd_ind : std_logic_Vector(31 downto 0) := (others => '0'); 	-- SAIDA INDICE RD DO IDEX
signal saida_mux_jalr : std_logic_Vector(4 downto 0) := (others => '0');-- SAIDA MUX SELETOR REG JALR
signal saida_mux4 : std_logic_Vector(4 downto 0) := (others => '0'); 		-- SAIDA MUX 4 SELETOR DE WR
signal saida_muxA : std_logic_Vector(31 downto 0) := (others => '0'); 	-- SAIDA MUX2_1 QUE ENTRA NA ULA
signal saida_muxB : std_logic_Vector(31 downto 0) := (others => '0'); 	-- SAIDA MUX2_2 QUE ENTRA NA ULA
signal saida_ula : std_logic_Vector(31 downto 0) := (others => '0'); 		-- SAIDA ULA
signal saida_somador_b : std_logic_Vector(31 downto 0):=(others => '0');-- SAIDA SOMADOR PC+4 E KTE SL2
signal exe_beq : std_logic := '0';
signal exe_bne : std_logic := '0';
signal zero : std_logic := 'Z';
signal ovfl: std_logic := 'Z';
signal exe_b_addrs : std_logic_Vector(31 downto 0) := (others => '0'); --Endereco que sai do adder de kte + pc + 4
-----------------------          MEMORY            ----------------------
signal mem_wb : std_logic_Vector(2 downto 0) := (others => '0'); 				-- SAIDA EX/MEM ENTRA MEM/WB
signal write_data : std_logic := '0'; 											-- ENTRADA ESCRITA MEM DADOS
signal read_data : std_logic := '0'; 												-- ENTRADA LEITURA MEM DADOS
signal mem_pc4 : std_logic_Vector(31 downto 0) := (others => '0'); 		-- SAIDA EX/MEM PC+4 ENTRADA MEM/WB
signal saida_mux_resul : std_logic_Vector(31 downto 0):=(others => '0');-- ENTRADA ADDRESS MEM DADOS
signal mem_rt : std_logic_Vector(31 downto 0) := (others => '0');				-- ENTRADA WRITE DATA
signal mem_indice : std_logic_Vector(4 downto 0) := (others => '0');		-- SAIDA INDICE BREG
signal mem_data : std_logic_Vector(31 downto 0) := (others => '0');			-- SAIDA MEM DADOS
-----------------------          WB                ----------------------
signal breg_write : std_logic := '0'; 											-- ENTRADA ESCRITA BREG
signal mux_sel_write_data : std_logic_Vector(1 downto 0):=(others=>'0');-- ENTRADA WD DO BREG
signal wb_pc4 : std_logic_Vector(31 downto 0) := (others => '0'); 			-- ENTRADA PC+4 MUX WB
signal ula_pc : std_logic_Vector(31 downto 0) := (others => '0'); 			-- ENTRADA ULA MUX WB
signal dados_mem : std_logic_Vector(31 downto 0) := (others => '0'); 		-- ENTRADA MEM DADOS MUX WB
signal saida_mux_breg : std_logic_Vector(31 downto 0) := (others =>'0');-- ENTRADA WD DO BREG
signal saida_indice_breg : std_logic_Vector(4 downto 0) :=(others=>'0');-- ENTRADA INDICE BREG
------------------------ Sinas para a utilizaÃƒÂ§ÃƒÂ£o do conversor de 7 segmentos ----------------
signal conversor0_in :  std_logic_vector(3 downto 0);
signal conversor1_in :  std_logic_vector(3 downto 0);
signal conversor2_in :  std_logic_vector(3 downto 0);
signal conversor3_in :  std_logic_vector(3 downto 0);
signal conversor4_in :  std_logic_vector(3 downto 0);
signal conversor5_in :  std_logic_vector(3 downto 0);
signal conversor6_in :  std_logic_vector(3 downto 0);
signal conversor7_in :  std_logic_vector(3 downto 0);
signal saida_conversor32 : std_logic_vector(31 downto 0);

begin
	clk_s <= NOT(clk);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO IF ----------------------
ifmux4 : mux4
	PORT MAP (
		Sel => sel_mux_pc,
		A => pc4,
		B => saida_somador_b,
		C => jump_mux_out,
		D => reg_rs,
		Z => mux_pc_out
		);

	sel_mux_pc(0) <= ((control_beq and comp) or (control_bne and (not comp)) or (control_jr));
	sel_mux_pc(1) <= (control_jr or control_j);

ifpc : pc
	PORT MAP (
		clk => clk,
		PC_in => mux_pc_out,
		PC_out => pc_init
	);

ifmem : meminst
	PORT MAP (
		clock		=> clk_s,
		address		=> pc_init(7 downto 0),
		q		=> mem_inst_out
	);

ifsomador : somador
	port map(	a => pc_init,
				b => X"00000004",
				result => pc4
		);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO IF/ID ----------------------
ifid_pipeline : regifid
	port map (
		clk => clk,
		PC4_in => pc4,
		instruction_in => mem_inst_out,
		PC4_out => id_pc4,
		instruction_out => instrucao
	);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO ID ----------------------
kte_shift(15 downto 0) <= instrucao(15 downto 0);
kte_shift(31 downto 16) <= (others => instrucao(15));
jump_mux_out <= id_pc4(31 downto 28) & instrucao(25 downto 0) & "00";

idcontrole : controle
	port map(
			Opcode=> instrucao(31 downto 26),
			Funct => instrucao(5 downto 0),
			WB => control_wb,
			MEM =>control_mem,
			EXE =>control_exe,
			jumps => control_j,
			jr =>control_jr,
			beq =>control_beq,
			bne =>control_bne
		);

idbreg : breg
	port map (
		clk => clk_s,
		wren => breg_write,
		radd1 => instrucao(25 downto 21),
		radd2 => instrucao(20 downto 16),
		wadd => saida_indice_breg,
		wdata => saida_mux_breg,
		r1 => reg_rs,
		r2 => reg_rt
		);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO ID/EX ----------------------
idex_pipeline : regidex
	port map (
	  -- entradas --
		clk => clk,
		control_wb_in => control_wb,
		control_mem_in => control_mem,
		control_exec_in => control_exe,
		PC4_in =>  id_pc4,
		read_data1_in => reg_rs,
		read_data2_in => reg_rt,
		sign_ext_imm_in => kte_shift,
		shamnt_in => instrucao(10 downto 6),
		reg_rt_in => instrucao(20 downto 16),
		reg_rd_in => instrucao(15 downto 11),
		beq_in => control_beq,
		bne_in => control_bne,
		-- saidas --
		control_wb_out => pipe_wb,
		control_mem_out => pipe_mem,
		reg_dst_out => pipe_exe(7 downto 6),
		aluOP_out => pipe_exe(5 downto 2),
		aluSRC1_out => pipe_exe(0),
		aluSRC2_out => pipe_exe(1),
		PC4_out => pipe_pc4,
		read_data1_out => pipe_rs,
		read_data2_out => pipe_rt,
		sign_ext_imm_out => pipe_kte,
		shamnt_out => pipe_shamt,
		reg_rt_out => pipe_rt_ind(4 downto 0),
		reg_rd_out => pipe_rd_ind(4 downto 0),
		beq_out => exe_beq,
		bne_out => exe_bne
		);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO EX ----------------------
shift_kte <= std_logic_vector(SHIFT_LEFT(unsigned(pipe_kte),2));
shamnt_32 <= X"000000" & "000" & pipe_shamt;
or_rd <= (instrucao(20) or instrucao(19) or instrucao(18) or instrucao(17) or instrucao(16));

exmux2_jalr : Mux2
	port map (
		Sel => or_rd,
		A => pipe_rd_ind,
		B => X"0000001F",
		Z => saida_mux2
		);

exmux2_1 : mux2
	port map(			--CHECAR SE O MUX A ESTA CERTO MESMO
		Sel => pipe_exe(0),
		A => pipe_rs,
		B => shamnt_32,
		Z => saida_muxA
		);

exmux2_2 : mux2
	port map(
		Sel => pipe_exe(1),
		A => pipe_rt,
		B => pipe_kte,
		Z => saida_muxB
		);

exmux4_indice : mux4
	port map (
		Sel => pipe_exe(7 downto 6),
		A => pipe_rt_ind,
		B => pipe_rd_ind,
		C => X"0000001F",
		D => saida_mux2,
		Z => saida_mux4_32
		);

idcomparador : comparador
	port map (
		a => reg_rs,
		b => reg_rt,
		result => comp
		);

exsomador : somador
	port map(
			a => pipe_pc4,
			b => shift_kte,
			result => exe_b_addrs
		);

SUBTRATOR_EX : Somador
	port map(
			a => exe_b_addrs,
			b => X"FFFFFFF8",
			result => saida_somador_b
		);

exula : ula
	port map (
	opcode => pipe_exe(5 downto 2),
	A => saida_muxA,
	B => saida_muxB,
	Z => saida_ula,
	zero => zero,											-- Alta impedÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ncia pois nÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â© utilizado
	ovfl => ovfl											-- Alta impedÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ncia pois nÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â£o ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â© utilizado
);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO EX/MEM ----------------------
exmem_pipeline : regexmem
	port map (
		clk => clk,
		-- entradas --
		control_wb_in => pipe_wb,
		control_mem_in => pipe_mem,
		PC4_shift_in => pipe_pc4,
		ula_result_in => saida_ula,
		writa_data_in => pipe_rt,
		write_reg_dst_in => saida_mux4_32(4 downto 0),
		-- saidas --
		control_wb_out => mem_wb,
		PC4_shift_out => mem_pc4,
		mem_read_out => read_data,
		mem_write_out => write_data,
		adress_out => saida_mux_resul,
		write_data_out => mem_rt,
		write_reg_dst_out => mem_indice
	);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO MEM ----------------------
mem_memdados : memdados
	port map (
		address		=> saida_mux_resul(7 downto 0),
		clock		=> clk_s,
		data		=> mem_rt,
		wren		=> write_data,
		q			=> mem_data
	);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO MEM/WB ----------------------
memwb_pipeline : regmemwb
	port map (
		clk => clk,
		-- entradas --
		control_wb_in => mem_wb,
		read_data_in => mem_data,
		resul_ula_in => saida_mux_resul,
		write_register_in => mem_indice,
		PC4_shift_in => mem_pc4,
		-- saidas --
		reg_write_out => breg_write,
		mem_to_reg_out => mux_sel_write_data,
		write_data_breg_out => dados_mem,
		data_ula_out => ula_pc,
		reg_dst_out => saida_indice_breg,
		PC4_shift_out => wb_pc4
		);

------------------------------- ESTÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚ÂGIO WB ----------------------
wbmux4 : mux4
	port map(
		Sel => mux_sel_write_data,
		A => ula_pc,
		B => dados_mem,
		C => wb_pc4,
		D => "00000000000000000000000000000000",					-- ALTA IMPEDANCIA PARA VETOR
		Z => saida_mux_breg
		);

------------------------------- SAiDAS DE VERIFICACAO DO FUNCIONAMENTO ----------------------
	Muxpc_out <= mux_pc_out;
	MEMI_out <= mem_inst_out;
	WB_out <= control_wb;
	EXE_out <= control_exe;
	BREGrs_out <= reg_rs;
	BREGrt_out <= reg_rt;
	MEM_out <= control_mem;
	ULA_out <= saida_ula;
	MUXindice_out <= saida_mux4_32(4 downto 0);
	MEMD_out <= mem_data;
	MUXdado_out <= saida_mux_breg;
	mux1_out <= saida_muxA;
	mux2_out <= saida_muxB;
	PCendwb <= wb_pc4;
	muxS0 <= sel_mux_pc(0);
	muxS1 <= sel_mux_pc(1);
	--------------------------- SAIDAS DA IMPLEMENTACAO DO FPGA -----------------
	mux4_saida_FPGA : mux4
	PORT MAP(
		Sel => sel_saida_chaves,
		A =>  pc_init,
		B =>	instrucao,
		C =>	mem_data,
		D =>	saida_ula,
		Z => saida_conversor32
	);

	conversor7_in <= saida_conversor32(31 downto 28);
	conversor6_in <= saida_conversor32(27 downto 24);
	conversor5_in <= saida_conversor32(23 downto 20);
	conversor4_in <= saida_conversor32(19 downto 16);
	conversor3_in <= saida_conversor32(15 downto 12);
	conversor2_in <= saida_conversor32(11 downto 8);
	conversor1_in <= saida_conversor32(7 downto 4);
	conversor0_in <= saida_conversor32(3 downto 0);


	conversor_7 : conversor7seg
	PORT MAP(
		data => conversor7_in,
		Z => saida_conversor7
		);

  conversor_6 : conversor7seg
  PORT MAP(
		data => conversor6_in,
		Z => saida_conversor6
		);

  conversor_5 : conversor7seg
	PORT MAP(
		data => conversor5_in,
		Z => saida_conversor5
    );

	conversor_4 : conversor7seg
	PORT MAP(
		data => conversor4_in,
		Z => saida_conversor4
		);

	conversor_3 : conversor7seg
	PORT MAP(
		data => conversor3_in,
		Z => saida_conversor3
		);

	conversor_2 : conversor7seg
	PORT MAP(
		data => conversor2_in,
		Z => saida_conversor2
		);

	conversor_1 : conversor7seg
	PORT MAP(
		data => conversor1_in,
		Z => saida_conversor1
		);

	conversor_0 : conversor7seg
	PORT MAP(
		data => conversor0_in,
		Z => saida_conversor0
		);



end architecture;
