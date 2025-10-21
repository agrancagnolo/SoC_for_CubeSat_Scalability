// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

/*
 * I/O mapping for analog
 *
 * mprj_io[37]  io_in/out/oeb/in_3v3[26]  ---                    ---
 * mprj_io[36]  io_in/out/oeb/in_3v3[25]  ---                    ---
 * mprj_io[35]  io_in/out/oeb/in_3v3[24]  gpio_analog/noesd[17]  ---
 * mprj_io[34]  io_in/out/oeb/in_3v3[23]  gpio_analog/noesd[16]  ---
 * mprj_io[33]  io_in/out/oeb/in_3v3[22]  gpio_analog/noesd[15]  ---
 * mprj_io[32]  io_in/out/oeb/in_3v3[21]  gpio_analog/noesd[14]  ---
 * mprj_io[31]  io_in/out/oeb/in_3v3[20]  gpio_analog/noesd[13]  ---
 * mprj_io[30]  io_in/out/oeb/in_3v3[19]  gpio_analog/noesd[12]  ---
 * mprj_io[29]  io_in/out/oeb/in_3v3[18]  gpio_analog/noesd[11]  ---
 * mprj_io[28]  io_in/out/oeb/in_3v3[17]  gpio_analog/noesd[10]  ---
 * mprj_io[27]  io_in/out/oeb/in_3v3[16]  gpio_analog/noesd[9]   ---
 * mprj_io[26]  io_in/out/oeb/in_3v3[15]  gpio_analog/noesd[8]   ---
 * mprj_io[25]  io_in/out/oeb/in_3v3[14]  gpio_analog/noesd[7]   ---
 * mprj_io[24]  ---                       ---                    user_analog[10]
 * mprj_io[23]  ---                       ---                    user_analog[9]
 * mprj_io[22]  ---                       ---                    user_analog[8]
 * mprj_io[21]  ---                       ---                    user_analog[7]
 * mprj_io[20]  ---                       ---                    user_analog[6]  clamp[2]
 * mprj_io[19]  ---                       ---                    user_analog[5]  clamp[1]
 * mprj_io[18]  ---                       ---                    user_analog[4]  clamp[0]
 * mprj_io[17]  ---                       ---                    user_analog[3]
 * mprj_io[16]  ---                       ---                    user_analog[2]
 * mprj_io[15]  ---                       ---                    user_analog[1]
 * mprj_io[14]  ---                       ---                    user_analog[0]
 * mprj_io[13]  io_in/out/oeb/in_3v3[13]  gpio_analog/noesd[6]   ---
 * mprj_io[12]  io_in/out/oeb/in_3v3[12]  gpio_analog/noesd[5]   ---
 * mprj_io[11]  io_in/out/oeb/in_3v3[11]  gpio_analog/noesd[4]   ---
 * mprj_io[10]  io_in/out/oeb/in_3v3[10]  gpio_analog/noesd[3]   ---
 * mprj_io[9]   io_in/out/oeb/in_3v3[9]   gpio_analog/noesd[2]   ---
 * mprj_io[8]   io_in/out/oeb/in_3v3[8]   gpio_analog/noesd[1]   ---
 * mprj_io[7]   io_in/out/oeb/in_3v3[7]   gpio_analog/noesd[0]   ---
 * mprj_io[6]   io_in/out/oeb/in_3v3[6]   ---                    ---
 * mprj_io[5]   io_in/out/oeb/in_3v3[5]   ---                    ---
 * mprj_io[4]   io_in/out/oeb/in_3v3[4]   ---                    ---
 * mprj_io[3]   io_in/out/oeb/in_3v3[3]   ---                    ---
 * mprj_io[2]   io_in/out/oeb/in_3v3[2]   ---                    ---
 * mprj_io[1]   io_in/out/oeb/in_3v3[1]   ---                    ---
 * mprj_io[0]   io_in/out/oeb/in_3v3[0]   ---                    ---
 *
 */

/*
 *----------------------------------------------------------------
 *
 * user_analog_proj_example
 *
 * This is an example of a (trivially simple) analog user project,
 * showing how the user project can connect to the I/O pads, both
 * the digital pads, the analog connection on the digital pads,
 * and the dedicated analog pins used as an additional power supply
 * input, with a connected ESD clamp.
 *
 * See the testbench in directory "mprj_por" for the example
 * program that drives this user project.
 *
 *----------------------------------------------------------------
 */

//`include "adc_module.v"
//`include "analog_signal_generator.v"

`default_nettype none

module signal_generator #(
    parameter PASO_DEF = 32'h5FA4,
    parameter [31:0] ENABLE_ADDRESS     = 32'h3000_0000, // read
    parameter [31:0] FREQUENCY_ADDRESS  = 32'h3000_0004, // read
    parameter [31:0] PHI_P_ADDRESS      = 32'h3000_0008, // write
    parameter [31:0] PHI_L1_ADDRESS     = 32'h3000_000C, // write
    parameter [31:0] PHI_L2_ADDRESS     = 32'h3000_0010, // write
    parameter [31:0] PHI_R_ADDRESS      = 32'h3000_0014, // write
    parameter [31:0] CLOCK_ADDRESS      = 32'h3000_0018, // read
    parameter [31:0] RETURN_ADDRESS     = 32'h3000_001C  // read
    ) (
    `ifdef USE_POWER_PINS
        inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
    `endif
   // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o,

    // // Logic Analyzer Signals
    // input  [127:0] la_data_in,
    // output [127:0] la_data_out,
    // input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in,
    //input  [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in_3v3,
    output reg [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_oeb,

    // // GPIO-analog
    // inout [`MPRJ_IO_PADS-`ANALOG_PADS-10:0] gpio_analog,
    // inout [`MPRJ_IO_PADS-`ANALOG_PADS-10:0] gpio_noesd,

    // // Dedicated analog
    inout [`ANALOG_PADS-1:0] io_analog
    // inout [2:0] io_clamp_high,
    // inout [2:0] io_clamp_low,

    // // Clock
    // input   user_clock2,

    // IRQ
    //output [2:0] irq
    );

    /*
    // Registro para el contador
    reg [31:0] contador = 0;
    reg [31:0] valor_final = 0;
    //reg reset_values = 0;
    reg [1:0] sent;

    wire   toggle;
    assign toggle = io_in[7]; // Ingreso del pulso*/

    // "PUERTOS"
    wire         i_test;
    reg  [2:0]   o_test;

    wire         i_enable;
    wire         i_f_select_serial; 
    wire         i_load_config; 
    reg   [3:0]  i_f_select;
    wire         i_clk;   
    reg          o_phi_p;
    reg          o_phi_l1;
    reg          o_phi_l2;
    reg          o_phi_r;

    // PARTE ANALOGICA
    wire         i_adc_data_p_ch1;
    wire         i_adc_data_n_ch1;
    wire         i_adc_data_p_ch2;
    wire         i_adc_data_n_ch2;
    reg          o_adc_data_ch1;
    reg          o_adc_data_ch2;
    reg          o_conv_finished_ch1;
    reg          o_conv_finished_ch2;
    wire         i_load;
    reg          i_conv_start;
    wire         i_data_config;
    wire         i_reset;    
    //wire adc_start_conversion;
   
 

    //ANALOGICA
    assign i_adc_data_p_ch1 = io_analog[9];
    assign i_adc_data_n_ch1 = io_analog[8];
    assign i_adc_data_p_ch2 = io_analog[7];
    assign i_adc_data_n_ch2 = io_analog[6];
    assign i_load           = io_in[18];
    assign i_data_config    = io_in[19];
    assign i_reset          = io_in[20];

    // DIGITAL
    assign i_test = io_in[26];
    assign i_clk = io_in[25];
    assign i_enable = io_in[24];
    assign i_f_select_serial = io_in[23];
    assign i_load_config = io_in[22];


     // LOCALPARAM 
    localparam MIN_TIEMPO_REQ =   CICLOS_FORMAS_DE_ONDA * 2052+PHI_P_WIDTH;
    localparam CICLOS_FORMAS_DE_ONDA =   16;
    localparam CICLOS_PHI_L =   CICLOS_FORMAS_DE_ONDA/2;
    localparam CICLOS_PHI_R =   CICLOS_FORMAS_DE_ONDA/4;


    

    // REGISTROS INTERNOS
    reg [31:0]  contador;
    reg [13:0]  contador_waves;
    reg [3:0]   f_selected;
    reg [1:0]   estado; 
    reg [1:0]   sig_estado;
    reg [$clog2(CICLOS_FORMAS_DE_ONDA):0] ciclos;
    reg pulse_ended;

    reg [3:0]   f_sel_sr;  
    reg [2:0]   f_sel_bit_counter; 

    reg         i_enable_wb;
    reg         i_clk_wb;
    reg [3:0]   i_f_select_wb;

    wire        i_enable_mux;
    wire [3:0]  i_f_select_mux;
    wire        i_clk_mux;

    reg i_test_reg;

    assign  io_oeb = {(`MPRJ_IO_PADS-`ANALOG_PADS){1'b0}};// always enabled

    // ASIGNACION DE SERIE A PARALELO DEL SELECTOR DE FRECUENCIAS
    always @(posedge i_clk_mux ) begin
        if (~i_enable_mux || (i_test && ~i_test_reg)) begin
            f_sel_sr <= 4'b0;
            f_sel_bit_counter <= 4'b0;
        end
        else begin
            if (i_load_config == 1) begin
                f_sel_sr <= {f_sel_sr[2:0], i_f_select_serial}; // Desplazar un bit
                f_sel_bit_counter <= f_sel_bit_counter + 1;
            end
            
            if (f_sel_bit_counter == 3'b100) begin
                i_f_select <= f_sel_sr;
                f_sel_bit_counter <= 4'b0;
            end
        end
    end

    // DECODIFICACION DE LOS ESTADOS
    localparam  [1:0] INITIAL_SETUP   = 2'b00;
    localparam  [1:0] SHIFT_CHARGES   = 2'b01;
    localparam  [1:0] HOLD_CAPTURE    = 2'b10;
    localparam  [1:0] PULSE_HPND      = 2'b11;
    localparam  PHI_P_WIDTH	      = 4;	

    initial begin
        o_phi_r = 0;
        o_phi_l2 = 0;
        o_phi_l1 = 0;
        o_phi_p = 0;
        contador = 0;
        contador_waves = 0;
        f_selected = 0;
        estado = 0;
        sig_estado = 0;
        ciclos = 0;
        o_test = 3'b0;
    end

// Actualizar el valor de i_test_reg al final del ciclo de reloj
always @(posedge wb_clk_i) begin
    i_test_reg <= i_test;
end

//ACTUALIZAR EL VALOR DE F_SELECTED
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Flanco positivo de i_test detectado
        f_selected <= 0;
    else if (estado == PULSE_HPND  && sig_estado == SHIFT_CHARGES)
        f_selected <= i_f_select_mux;
end

//FLAG PARA CONTROLAR EL FINAL DEL PULSO
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear en flanco de i_test
        pulse_ended <= 0;
    else if ((estado == PULSE_HPND)  && (sig_estado == SHIFT_CHARGES))
        pulse_ended <= 1;
    else
        pulse_ended <= 0;    
end

//CONTADOR PRINCIPAL
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador
        contador <= 0;
    else if ((estado == PULSE_HPND)  && (sig_estado == SHIFT_CHARGES))
        contador <= 0;
    else
        contador <= contador + 1;
end

//CONTADOR DE CICLOS DE RELOJ PARA GENERAR LAS WF
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador de ciclos
        ciclos <= 0;
    else if ((ciclos < (CICLOS_FORMAS_DE_ONDA-1)) & (estado == SHIFT_CHARGES))
        ciclos <= ciclos + 1;
    else  
        ciclos <= 0;
end

//CONTADOR DE VECES QUE SE GENERARON LAS ONDAS PHI_L1, PHI_L2 Y PHI_R
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador de ondas
        contador_waves <= 0;
    else if (estado == PULSE_HPND)
        contador_waves <= 0;
    else if (ciclos == CICLOS_FORMAS_DE_ONDA-1)
        contador_waves <= contador_waves + 1;
end


//MAQUINA DE ESTADOS FINITOS 

// TRANSICIÓN SINCRÓNICA DE ESTADO
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear estado
        estado <= INITIAL_SETUP;
    else 
        estado <= sig_estado;
end

//DECODIFICACION DEL SIGUIENTE ESTADO
always @(*) begin
    case (estado)
    INITIAL_SETUP: begin
        if(( contador > PHI_P_WIDTH) && (contador_waves == 0))
    	    sig_estado = SHIFT_CHARGES;   
        else 
            sig_estado = INITIAL_SETUP; 
	
    end
    SHIFT_CHARGES: begin
        if ( contador_waves <= 2051 )
            sig_estado = SHIFT_CHARGES;
        else 
            sig_estado = HOLD_CAPTURE;   
    end
    HOLD_CAPTURE: begin
        if ( contador <= (MIN_TIEMPO_REQ + (f_selected * PASO_DEF )))
            sig_estado = HOLD_CAPTURE;
        else 
            sig_estado = PULSE_HPND;  
    end
    PULSE_HPND: begin
        if ( contador <= (MIN_TIEMPO_REQ + (f_selected * PASO_DEF ) + PHI_P_WIDTH)) // PHI_P_WIDTH  >  320ns
            sig_estado = PULSE_HPND;
        else 
            sig_estado = SHIFT_CHARGES;  
    end
    endcase
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && ciclos>=CICLOS_PHI_L  && ciclos <CICLOS_PHI_L+CICLOS_PHI_R) || (estado==PULSE_HPND) ||(estado==INITIAL_SETUP))
        o_phi_r =1;
    else 
        o_phi_r =0;    
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && (ciclos>=CICLOS_PHI_L)) | (estado==PULSE_HPND) ||(estado==INITIAL_SETUP))
        o_phi_l2 =1;
    else 
        o_phi_l2 =0;    
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && (ciclos<CICLOS_PHI_L)) )
        o_phi_l1 =1;
    else 
        o_phi_l1 =0;    
end

always @(*) begin
    if ((estado==PULSE_HPND) ||(estado==INITIAL_SETUP) ) begin
        o_phi_p =1;
    end else begin
        o_phi_p =0;   
    end
end

//LOGICA WISHBONE
always @(posedge wb_clk_i) begin
    if(i_test) begin
        if(wb_rst_i) begin
            wbs_dat_o <= 32'b0;
        end else begin
            // Write
            if (wbs_stb_i && wbs_cyc_i && wbs_we_i) begin
                case(wbs_adr_i)
                    ENABLE_ADDRESS: i_enable_wb <= wbs_dat_i[0];
                    FREQUENCY_ADDRESS: i_f_select_wb <= wbs_dat_i[3:0];
                    CLOCK_ADDRESS: i_clk_wb <= wbs_dat_i[0];
                    RETURN_ADDRESS: o_test <= wbs_dat_i[2:0];
                    default: wbs_dat_o <= 32'b0;
                endcase
            end
            // Handle Read Operations
            if (wbs_stb_i && wbs_cyc_i && !wbs_we_i) begin
                case(wbs_adr_i)
                    PHI_P_ADDRESS: wbs_dat_o <= {31'b0, o_phi_p};
                    PHI_L1_ADDRESS: wbs_dat_o <= {31'b0, o_phi_l1};
                    PHI_L2_ADDRESS: wbs_dat_o <= {31'b0, o_phi_l2};
                    PHI_R_ADDRESS: wbs_dat_o <= {31'b0, o_phi_r};
                    default: wbs_dat_o <= 32'b0;
                endcase
            end
        end
    end
end

assign i_enable_mux = i_test ? i_enable_wb : i_enable ;

assign i_clk_mux = i_test ? i_clk_wb : i_enable ;

assign i_f_select_mux = i_test ? i_f_select_wb : i_f_select ;


    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            io_out[9:7] <= 0;
        end 
        else begin
            io_out[9:7] <= o_test;
        end
    end

    always @(posedge i_clk_mux) begin
        io_out[6:0] <= 0;
        io_out[10] <= o_phi_p; 
        io_out[11] <= o_phi_l1;
        io_out[12] <= o_phi_l2;
        io_out[13] <= o_phi_r;
        io_out[14] <= o_adc_data_ch1; 
        io_out[15] <= o_adc_data_ch2;
        io_out[16] <= o_conv_finished_ch1;
        io_out[17] <= o_conv_finished_ch2;
        io_out[26:18] <= 0;
    end

    always @(posedge wb_clk_i) begin
        if(wb_rst_i)
            wbs_ack_o <= 0;
        else
            wbs_ack_o <= (wbs_stb_i && (wbs_adr_i == ENABLE_ADDRESS || wbs_adr_i == FREQUENCY_ADDRESS || wbs_adr_i == CLOCK_ADDRESS || wbs_adr_i == RETURN_ADDRESS || wbs_adr_i == PHI_P_ADDRESS || wbs_adr_i == PHI_L1_ADDRESS || wbs_adr_i == PHI_L2_ADDRESS || wbs_adr_i == PHI_R_ADDRESS));
        end

analog_signal_generator #(.CICLOS_FORMAS_DE_ONDA(CICLOS_FORMAS_DE_ONDA))
     analog_signal_gen0 (
        .i_enable(i_enable_mux),
        .i_clock(i_clk_mux),
        .contador(contador), 
        .i_phi_l2(o_phi_l2),
        .o_adc_start_conversion(adc_start_conversion)
    );

// INSTANCIACION ANALOGICA
wire [15:0] cfg1_1;
wire [15:0] cfg2_1;
wire [15:0] res_1;
wire adc_fin_1;
wire adc_fin_osr_1;

wire [15:0] cfg1_2;
wire [15:0] cfg2_2;
wire [15:0] res_2;
wire adc_fin_2;
wire adc_fin_osr_2;


adc_bridge adc_bridge1(
    .clk(i_clk_mux),            // clk for shift regs
    .rst_n(wb_rst_i),          // async. reset for regs
    .dat_i(i_data_config),          // serial in (ADC config, LSB first)
    .load(i_load),           // load strobe for shift regs
    // interface to ADC
    .adc_res(res_1),        // ADC result input
    .adc_conv_finished(adc_fin_1),
    .adc_conv_finished_osr(adc_fin_osr_1),
    .adc_cfg1(cfg1_1),       // ADC config1 output
    .adc_cfg2(cfg2_1),       // ADC config2 output
    // chip outputs
    .dat_o(o_adc_data_ch1),          // serial out (ADC result, LSB first)
    .conv_finish(o_conv_finished_ch1),    // flag that conversion is finished
    .tie1(),           // logic 1 aux. output
    .tie0()            // logic 2 aux. output
    );

adc_top  adc1 (
    `ifdef USE_POWER_PINS
        .VDD(vccd1),
        .VSS(vssd1),
    `endif
    .clk_vcm(i_clk_mux),
    .rst_n(wb_rst_i),
    .inp_analog(i_adc_data_p_ch1_buff),
    .inn_analog(i_adc_data_n_ch1_buff),
    .start_conversion_in(i_conv_start),   
    .config_1_in(cfg1_1),    
    .config_2_in(cfg2_1),    
    .result_out(res_1),    
    .conversion_finished_out(adc_fin_1),
    .conversion_finished_osr_out(adc_fin_osr_1)
);

adc_bridge adc_bridge2(
    .clk(i_clk_mux),            // clk for shift regs
    .rst_n(wb_rst_i),          // async. reset for regs
    .dat_i(i_data_config),          // serial in (ADC config, LSB first)
    .load(i_load),           // load strobe for shift regs
    // interface to ADC
    .adc_res(res_2),        // ADC result input
    .adc_conv_finished(adc_fin_2),
    .adc_conv_finished_osr(adc_fin_osr_2),
    .adc_cfg1(cfg1_2),       // ADC config1 output
    .adc_cfg2(cfg2_2),       // ADC config2 output
    // chip outputs
    .dat_o(o_adc_data_ch2),          // serial out (ADC result, LSB first)
    .conv_finish(o_conv_finished_ch2),    // flag that conversion is finished
    .tie1(),           // logic 1 aux. output
    .tie0()            // logic 2 aux. output
    );

adc_top  adc2 (
    `ifdef USE_POWER_PINS
        .VDD(vccd1),
        .VSS(vssd1),
    `endif
    .clk_vcm(i_clk_mux),
    .rst_n(wb_rst_i),
    .inp_analog(i_adc_data_p_ch2_buff),
    .inn_analog(i_adc_data_n_ch2_buff),
    .start_conversion_in(i_conv_start),   
    .config_1_in(cfg1_2),    
    .config_2_in(cfg2_2),    
    .result_out(res_2),    
    .conversion_finished_out(adc_fin_2),
    .conversion_finished_osr_out(adc_fin_osr_2)
);

wire i_adc_data_p_ch1_buff;
wire i_adc_data_n_ch1_buff;
wire i_adc_data_p_ch2_buff;
wire i_adc_data_n_ch2_buff;


sky130_ef_ip__opamp buffer1_p (
    `ifdef USE_POWER_PINS
        .vdd(vccd1),
        .vss(vssd1),
    `endif
    .inp(i_adc_data_p_ch1),
    .inn(i_adc_data_p_ch1_buff),
    .ena(1'b1),
    .out(i_adc_data_p_ch1_buff)
);

sky130_ef_ip__opamp buffer1_n (
    `ifdef USE_POWER_PINS
        .vdd(vccd1),
        .vss(vssd1),
    `endif
    .inp(i_adc_data_n_ch1),
    .inn(i_adc_data_n_ch1_buff),
    .ena(1'b1),
    .out(i_adc_data_n_ch1_buff)
);

sky130_ef_ip__opamp buffer2_p (
    `ifdef USE_POWER_PINS
        .vdd(vccd1),
        .vss(vssd1),
    `endif
    .inp(i_adc_data_p_ch2),
    .inn(i_adc_data_p_ch2_buff),
    .ena(1'b1),
    .out(i_adc_data_p_ch2_buff)
);

sky130_ef_ip__opamp buffer2_n (
    `ifdef USE_POWER_PINS
        .vdd(vccd1),
        .vss(vssd1),
    `endif
    .inp(i_adc_data_n_ch2),
    .inn(i_adc_data_n_ch2_buff),
    .ena(1'b1),
    .out(i_adc_data_n_ch2_buff)
);

endmodule
