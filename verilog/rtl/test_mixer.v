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

module test_mixer #(
    parameter   [31:0]  REG_SET_VALUE_ADDRESS  = 32'h3000_0000,// recibir valor
    parameter   [31:0]  RETURN_VALUE           = 32'h3000_0004,// enviar el valor 
    parameter   BITS_8 = 8
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
    
    // IRQ
    //assign irq = 3'b000;	// Unused

    // Registro para el contador
    reg [31:0] contador = 0;
    reg [31:0] valor_final = 0;
    //reg reset_values = 0;
    reg [1:0] sent;

    wire   toggle;
    assign toggle = io_in[7]; // Ingreso del pulso
    //assign io_in = {(`MPRJ_IO_PADS-`ANALOG_PADS){1'b0}};
    
    assign  io_oeb = {(`MPRJ_IO_PADS-`ANALOG_PADS){1'b0}};// always enabled
    initial 
    begin
            io_out = 0;
            sent = 2'b00;
    end
    // writes
    reg [(BITS_8-1):0]reg_set_value;

    always @(posedge wb_clk_i) begin
        if(wb_rst_i)
        begin
            reg_set_value <= {BITS_8{1'b0}};
            sent <= 0;
            //reset_values <= 0;
        end   
        else if(wbs_stb_i && wbs_cyc_i && wbs_we_i)
            case(wbs_adr_i)
                REG_SET_VALUE_ADDRESS:
                    begin
                        reg_set_value <= wbs_dat_i[(BITS_8-1):0]; 
                        if (reg_set_value == 8'd7)
                            begin 
                               //reset_values <= 1;
                               reg_set_value <= {BITS_8{1'b0}};
                               sent <= 2'b00;
                            end
                        if (reg_set_value == 8'd8)
                            begin
                               sent  <= 2'b01;
                               reg_set_value  <= 0;
                            end
                    end
                default:
                    wbs_dat_o <= 32'b0;
            endcase
        else if(wbs_stb_i && wbs_cyc_i && !wbs_we_i)
            case(wbs_adr_i)
                RETURN_VALUE:
                    if (sent == 2'b01)
                    begin
                        wbs_dat_o <= contador;  // Assign contador to wbs_dat_o  
                        sent  <= 2'b10;
                    end
                default:
                    wbs_dat_o <= 32'b0;
            endcase
        
    end

    //Sumador
    always @(posedge toggle) begin

        if(!sent) //sent=0
        begin
            contador <= contador + 1;
        end
        else if(sent == 2'b10)//sent==2
        begin
            contador <= 0;
        end
    end
    
    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            io_out[24] <= 0;
        end 
        else if(sent  <= 2'b01) 
        begin
            io_out[24] <=  1'b1; //Out pulse
        end
        else io_out[24] <=  1'b0; //Out pulse
    end

    always @(posedge wb_clk_i) begin
        if(wb_rst_i)
            wbs_ack_o <= 0;
        else
            wbs_ack_o <= (wbs_stb_i && (wbs_adr_i == REG_SET_VALUE_ADDRESS || wbs_adr_i == RETURN_VALUE));
        end

endmodule
