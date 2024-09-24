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

 
//`include "signal_selector.v"

`default_nettype none
`timescale 1ns/1ps

 
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
 )(
     input wire          i_wb_clk,
     input wire          i_wb_rst,
     input wire          i_wb_cyc,       // wishbone transaction
     input wire          i_wb_stb,       // strobe - data valid and accepted
     input wire          i_wb_we,        // write enable
     input wire  [31:0]  i_wb_addr,      // address
     input wire  [31:0]  i_wb_data,      // incoming data
     output reg          o_wb_ack,       // request is completed 
     output reg  [31:0]  o_wb_data,      // output data
     
     input  wire         i_test,
     output reg  [4:0]   o_test,

     input  wire         i_enable,
     input  wire   [3:0] i_f_select,
     input  wire         i_clk,
     output reg          o_phi_p,
     output reg          o_phi_l1,
     output reg          o_phi_l2,
     output reg          o_phi_r
 );
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
end

// Actualizar el valor de i_test_reg al final del ciclo de reloj
always @(posedge i_wb_clk) begin
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
always @(posedge i_wb_clk) begin
    if(i_test) begin
        if(i_wb_rst) begin
            o_wb_ack <= 0;
            o_wb_data <= 32'b0;
        end else begin
            // Write
            if (i_wb_stb && i_wb_cyc && i_wb_we) begin
                case(i_wb_addr)
                    ENABLE_ADDRESS: i_enable_wb <= i_wb_data[0];
                    FREQUENCY_ADDRESS: i_f_select_wb <= i_wb_data[3:0];
                    CLOCK_ADDRESS: i_clk_wb <= i_wb_data[0];
                    RETURN_ADDRESS: o_test <= i_wb_data[4:0];
                    default: o_wb_data <= 32'b0;
                endcase
            end
            // Handle Read Operations
            if (i_wb_stb && i_wb_cyc && !i_wb_we) begin
                case(i_wb_addr)
                    PHI_P_ADDRESS: o_wb_data <= {31'b0, o_phi_p};
                    PHI_L1_ADDRESS: o_wb_data <= {31'b0, o_phi_l1};
                    PHI_L2_ADDRESS: o_wb_data <= {31'b0, o_phi_l2};
                    PHI_R_ADDRESS: o_wb_data <= {31'b0, o_phi_r};
                    default: o_wb_data <= 32'b0;
                endcase
            end
            o_wb_ack <= (i_wb_stb && (i_wb_addr == ENABLE_ADDRESS || i_wb_addr == FREQUENCY_ADDRESS || i_wb_addr == CLOCK_ADDRESS || i_wb_addr == RETURN_ADDRESS || i_wb_addr == PHI_P_ADDRESS || i_wb_addr == PHI_L1_ADDRESS || i_wb_addr == PHI_L2_ADDRESS || i_wb_addr == PHI_R_ADDRESS));
        end
    end
end

signal_selector enable_mux(
    .i_phi_r(i_enable_wb),
    .i_phi_p(i_enable),
    .i_selector(i_test),
    .o_salida(i_enable_mux)
);

signal_selector clock_mux(
    .i_phi_r(i_clk_wb),
    .i_phi_p(i_clk),
    .i_selector(i_test),
    .o_salida(i_clk_mux)
);

signal_selector freq_mux0(
    .i_phi_r(i_f_select_wb[0]),
    .i_phi_p(i_f_select[0]),
    .i_selector(i_test),
    .o_salida(i_f_select_mux[0])
);

signal_selector freq_mux1(
    .i_phi_r(i_f_select_wb[1]),
    .i_phi_p(i_f_select[1]),
    .i_selector(i_test),
    .o_salida(i_f_select_mux[1])
);

signal_selector freq_mux2(
    .i_phi_r(i_f_select_wb[2]),
    .i_phi_p(i_f_select[2]),
    .i_selector(i_test),
    .o_salida(i_f_select_mux[2])
);

signal_selector freq_mux3(
    .i_phi_r(i_f_select_wb[3]),
    .i_phi_p(i_f_select[3]),
    .i_selector(i_test),
    .o_salida(i_f_select_mux[3])
);

endmodule


