`timescale 10ns/1ps


// Global parameters
`define __GLOBAL_DEFINE_H

`define MPRJ_IO_PADS_1 19	/* number of user GPIO pads on user1 side */
`define MPRJ_IO_PADS_2 19	/* number of user GPIO pads on user2 side */
`define MPRJ_IO_PADS (`MPRJ_IO_PADS_1 + `MPRJ_IO_PADS_2)

`define MPRJ_PWR_PADS_1 2	/* vdda1, vccd1 enable/disable control */
`define MPRJ_PWR_PADS_2 2	/* vdda2, vccd2 enable/disable control */
`define MPRJ_PWR_PADS (`MPRJ_PWR_PADS_1 + `MPRJ_PWR_PADS_2)

// Analog pads are only used by the "caravan" module and associated
// modules such as user_analog_project_wrapper and chip_io_alt.

`define ANALOG_PADS_1 5
`define ANALOG_PADS_2 6

`define ANALOG_PADS (`ANALOG_PADS_1 + `ANALOG_PADS_2)

// Size of soc_mem_synth

// Type and size of soc_mem
// `define USE_OPENRAM
`define USE_CUSTOM_DFFRAM
// don't change the following without double checking addr widths
`define MEM_WORDS 256

// Number of columns in the custom memory; takes one of three values:
// 1 column : 1 KB, 2 column: 2 KB, 4 column: 4KB
`define DFFRAM_WSIZE 4
`define DFFRAM_USE_LATCH 0

// not really parameterized but just to easily keep track of the number
// of ram_block across different modules
`define RAM_BLOCKS 1

// Clock divisor default value
`define CLK_DIV 3'b010

// GPIO control default mode and enable for most I/Os
// Most I/Os set to be user input pins on startup.
// NOTE:  To be modified, with GPIOs 5 to 35 being set from a build-time-
// programmable block.
`define MGMT_INIT 1'b0
`define OENB_INIT 1'b0
`define DM_INIT 3'b001

`include "signal_generator.v"
`include "analog_signal_generator.v"

module tb_signal_generator();

    parameter CLK_PERIOD=25;
    
    // Señales de entrada
    wire i_enable;
    wire i_f_select_serial;
    wire i_load_config;
    wire i_clk;
    
    
    // Señales de salida
    wire o_phi_p;
    wire o_phi_l1;
    wire o_phi_l2;
    wire o_phi_r;
    
    
    // Parámetros
    parameter PASO_DEF = 32'h5FA4;
    parameter [31:0] ENABLE_ADDRESS     = 32'h3000_0000; // read
    parameter [31:0] FREQUENCY_ADDRESS  = 32'h3000_0004; // read
    parameter [31:0] PHI_P_ADDRESS      = 32'h3000_0008; // write
    parameter [31:0] PHI_L1_ADDRESS     = 32'h3000_000C; // write
    parameter [31:0] PHI_L2_ADDRESS     = 32'h3000_0010; // write
    parameter [31:0] PHI_R_ADDRESS      = 32'h3000_0014; // write
    parameter [31:0] CLOCK_ADDRESS      = 32'h3000_0018; // read
    parameter [31:0] RETURN_ADDRESS     = 32'h3000_001C;// read

    // Señales de la interfaz Wishbone
    reg wb_clk_i;
    reg wb_rst_i;
    reg wbs_stb_i;
    reg wbs_cyc_i;
    reg wbs_we_i;
    reg [3:0] wbs_sel_i;
    reg [31:0] wbs_dat_i;
    reg [31:0] wbs_adr_i;
    wire wbs_ack_o;
    wire [31:0] wbs_dat_o;

    // IOs simulados
    reg [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_oeb;

        // Instancia del DUT (Device Under Test)
    signal_generator #(
        .PASO_DEF(PASO_DEF)
    ) dut (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(wbs_stb_i),
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_we_i(wbs_we_i),
        .wbs_sel_i(wbs_sel_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_adr_i(wbs_adr_i),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o),
        .io_in(io_in),
        .io_out(io_out),
        .io_oeb(io_oeb)
    );
    /*
    assign io_in[25] = i_clk;
    assign io_in[24] = i_enable;
    assign io_in[23] = i_f_select_serial;
    assign io_in[22] = i_load_config;
    */
    assign o_phi_p =    io_out[10]; 
    assign o_phi_l1 = 	io_out[11];
    assign o_phi_l2 =	io_out[12]; 
    assign o_phi_r =  	io_out[13];
    
    // Generación del reloj
    initial begin
        io_in[25] = 0;
        forever #(CLK_PERIOD/2) io_in[25] = ~io_in[25]; 
    end
    
    initial begin 
    	io_in[26] = 0;
    	
    	#30;
    	io_in[23] = 0;
    	io_in[22] = 1;
    	
    	
    	#(CLK_PERIOD*6);
    	io_in[22] = 0;
        #(28000*CLK_PERIOD);
	
	// freq_select = 4'd0
        
        io_in[22] = 1;
    	io_in[23] = 0;
    	#(CLK_PERIOD*3);
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[22] = 0;
    	#CLK_PERIOD;
    	
    	// freq_select = 4'd1
	#(40000*CLK_PERIOD);
	
        io_in[22] = 1;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[22] = 0;
    	#CLK_PERIOD;
    	
    	// freq_select = 4'd2
    	#(65000*CLK_PERIOD);
    
    	io_in[22] = 1;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[22] = 0;
    	#CLK_PERIOD;
    	
    	// freq_select = 4'd5
        #(130000*CLK_PERIOD);
        
        io_in[22] = 1;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[22] = 0;
    	#CLK_PERIOD;
    	
    	// freq_select = 4'd8
    	#(190000*CLK_PERIOD);
    	
    	io_in[22] = 1;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 0;
    	#CLK_PERIOD;
    	io_in[22] = 0;
    	#CLK_PERIOD;
    	
    	// freq_select = 4'd10
    	#(240000*CLK_PERIOD);
    	
    	
    	io_in[22] = 1;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[23] = 1;
    	#CLK_PERIOD;
    	io_in[22] = 1;
    	#CLK_PERIOD;
    	
    	// freq_select = 4'd15
    	#(2*275000*CLK_PERIOD);
	io_in[24] = 0;
    	
    	$finish;
    		
    end
    
    // Inicialización de las señales
    initial begin
        // Inicializa las señales
        io_in[24] = 0;
        
        // Estimulación de la FSM
        #(CLK_PERIOD*2);
        io_in[24] = 1;
        io_in[26] = 0;

        
        // Deja correr la simulación por un tiempo
        #40000;

        

        #1500000;
        #40000;
        #40000;
        // Deshabilita la FSM
        
        
        // Fin de la simulación
        #100;
        
    end
    
    // Monitoreo de señales
    initial begin
        $dumpfile("wf_signal_generator.vcd");
        $dumpvars(0, tb_signal_generator);
        $monitor("Time: %0t | enable: %b | f_select: %b | phi_p: %b | phi_l1: %b | phi_l2: %b | phi_r: %b",
                 $time, i_enable, i_f_select_serial, o_phi_p, o_phi_l1, o_phi_l2, o_phi_r);
    end

endmodule
