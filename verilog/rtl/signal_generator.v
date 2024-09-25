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
    output [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_oeb

    // // GPIO-analog
    // inout [`MPRJ_IO_PADS-`ANALOG_PADS-10:0] gpio_analog,
    // inout [`MPRJ_IO_PADS-`ANALOG_PADS-10:0] gpio_noesd,

    // // Dedicated analog
    // inout [`ANALOG_PADS-1:0] io_analog,
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
    reg  [4:0]   o_test;

    wire         i_enable;
    wire   [3:0] i_f_select;
    wire         i_clk;
    reg          o_phi_p;
    reg          o_phi_l1;
    reg          o_phi_l2;
    reg          o_phi_r;

    assign i_test = io_in[7];
    assign i_clk = io_in[13];
    assign i_enable = io_in[22];
    assign i_f_select = io_in[26:23];


    localparam [31:0] MIN_TIEMPO_REQ =   32'h1009;

    // REGISTROS INTERNOS
    reg [31:0]  contador;
    reg [13:0]  contador_waves;
    reg [3:0]   f_selected;
    reg [1:0]   estado, sig_estado, ciclos;
    reg pulse_ended;

    reg         i_enable_wb;
    reg         i_clk_wb;
    reg [3:0]   i_f_select_wb;

    wire        i_enable_mux;
    wire [3:0]  i_f_select_mux;
    wire        i_clk_mux;

    reg i_test_reg;


    assign  io_oeb = {(`MPRJ_IO_PADS-`ANALOG_PADS){1'b0}};// always enabled

    // DECODIFICACION DE LOS ESTADOS
    localparam  [1:0] INITIAL_SETUP   = 2'b00;
    localparam  [1:0] SHIFT_CHARGES   = 2'b01;
    localparam  [1:0] HOLD_CAPTURE    = 2'b10;
    localparam  [1:0] PULSE_HPND      = 2'b11;
    localparam  PHI_P_WIDTH		  = 18;	

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
        o_test = 5'b0;
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
    else if (estado == PULSE_HPND  & sig_estado == SHIFT_CHARGES)
        pulse_ended <= ~pulse_ended;
    else
        pulse_ended <= 0;    
end

//CONTADOR PRINCIPAL
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador
        contador <= 0;
    else if (pulse_ended)
        contador <= 0;
    else
        contador <= contador + 1;
end

//CONTADOR DE CICLOS DE RELOJ PARA GENERAR LAS WF
always @(posedge i_clk_mux) begin
    if (~i_enable_mux || (i_test && ~i_test_reg))  // Resetear contador de ciclos
        ciclos <= 0;
    else if ((ciclos < 3) & (estado == SHIFT_CHARGES))
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
    else if (ciclos == 3)
        contador_waves <= contador_waves + 1;
end

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
        if ( contador <= (MIN_TIEMPO_REQ + (f_selected * PASO_DEF ) + 4*PHI_P_WIDTH )) // PHI_P_WIDTH  >  320ns
            sig_estado = PULSE_HPND;
        else 
            sig_estado = SHIFT_CHARGES;  
    end
    endcase
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && ciclos==2) || (estado==PULSE_HPND) ||(estado==INITIAL_SETUP))
        o_phi_r =1;
    else 
        o_phi_r =0;    
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && (ciclos==2 || ciclos==3)) | (estado==PULSE_HPND) ||(estado==INITIAL_SETUP))
        o_phi_l2 =1;
    else 
        o_phi_l2 =0;    
end

always @(*) begin
    if ((estado==SHIFT_CHARGES && (ciclos==0 || ciclos==1)) )
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
                    RETURN_ADDRESS: o_test <= wbs_dat_i[4:0];
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
            io_out[12:8] <= 0;
        end 
        else begin
            io_out[12:8] <= o_test;
        end
    end

    always @(posedge i_clk_mux) begin
        io_out[7:0] <= 0;
        io_out[14:13] <= 0;
        io_out[15] <= o_phi_l2;
        io_out[16] <= o_phi_l1;
        io_out[17] <= o_phi_r;
        io_out[18] <= o_phi_p;    
        io_out[26:19] <= 0;
    end

    always @(posedge wb_clk_i) begin
        if(wb_rst_i)
            wbs_ack_o <= 0;
        else
            wbs_ack_o <= (wbs_stb_i && (wbs_adr_i == ENABLE_ADDRESS || wbs_adr_i == FREQUENCY_ADDRESS || wbs_adr_i == CLOCK_ADDRESS || wbs_adr_i == RETURN_ADDRESS || wbs_adr_i == PHI_P_ADDRESS || wbs_adr_i == PHI_L1_ADDRESS || wbs_adr_i == PHI_L2_ADDRESS || wbs_adr_i == PHI_R_ADDRESS));
        end

endmodule
