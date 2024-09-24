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

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_analog_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user analog project.
 *
 *-------------------------------------------------------------
 */


`timescale 1ns/1ps

module designs_wrapper(

  `ifdef USE_POWER_PINS
        inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
    `endif

     // wb interface
    input           i_wb_clk,
    input           i_wb_rst,
    input           i_wb_cyc,       // wishbone transaction
    input           i_wb_stb,       // strobe - data valid and accepted as long as !o_wb_stall
    input           i_wb_we,        // write enable
    input   [31:0]  i_wb_addr,      // address
    input   [31:0]  i_wb_data,      // incoming data
    output          o_wb_ack,       // request is completed 
    output  [31:0]  o_wb_data,      // output data

    // Logic Analyzer Signals
    //input  [127:0] la_data_in,
    //output [127:0] la_data_out,
    //input  [127:0] la_oenb,

    // IOs
    input         i_signal_sel,
    input         i_enable,
    input  [3:0]  i_freq_sel,
    input         i_clock,
    input         i_test,
    output [4:0]  o_test,
    //output [6:0]  io_out,

    output        o_pixel_flag,
    output        o_control_signal,
    output        o_ADC_frame,
    output        o_phi_p,
    output        o_phi_r,
    output        o_phi_l1,
    output        o_phi_l2,
    output [19:0]  io_oeb

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    //inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    //input   user_clock2,

    // User maskable interrupt signals
    //output [2:0] user_irq
  );


  // IOs
  //wire    [`MPRJ_IO_PADS-1:0] io_in;
  //wire    [`MPRJ_IO_PADS-1:0] io_out;
  //wire    [`MPRJ_IO_PADS-1:0] io_oeb;

  // Analog (direct connection to GPIO pad---use with caution)
  // Note that analog I/O is not available on the 7 lowest-numbered
  // GPIO pads, and so the analog_io indexing is offset from the
  // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).

  //wire [`MPRJ_IO_PADS-10:0] analog_io,

  // Independent clock (on independent integer divider)
  //input   user_clock2,

  // User maskable interrupt signals
  //output [2:0] user_irq

  assign  {o_ADC_frame, o_pixel_flag, o_control_signal} = 
          {ADC_frame, pixel_flag, control_signal};

  assign  {o_phi_p, o_phi_l1, o_phi_l2, o_phi_r} = 
          {phi_p, phi_l1, phi_l2, phi_r};
  
  assign io_oeb = 20'b00000111111100111110;


  assign enable = i_enable;
  assign f_select = i_freq_sel;
  assign selector = i_signal_sel;


  wire        enable;
  wire [3:0]  f_select;
  wire        phi_p;
  wire        phi_l1;
  wire        phi_l2;
  wire        phi_r;
  wire        pixel_flag;
  wire        ADC_frame;
  wire        control_signal;
  wire        selector;

  signal_generator signal_gen0 (
                     .i_wb_clk(i_wb_clk),
                     .i_wb_rst(i_wb_rst),
                     .i_wb_cyc(i_wb_cyc),
                     .i_wb_stb(i_wb_stb),
                     .i_wb_we(i_wb_we),
                     .i_wb_addr(i_wb_addr),
                     .i_wb_data(i_wb_data),
                     .o_wb_ack(o_wb_ack),
                     .o_wb_data(o_wb_data),
                     .i_enable(enable),
                     .i_f_select(f_select),
                     .i_clk(i_clock),
                     .i_test(i_test),
                     .o_test(o_test),
                     .o_phi_p(phi_p),
                     .o_phi_l1(phi_l1),
                     .o_phi_l2(phi_l2),
                     .o_phi_r(phi_r)
                   );
  
  analog_signal_generator analog_signal_gen0(
                            .i_enable(enable),
                            .i_phi_l2(phi_l2),
                            .i_phi_p(phi_p),
                            .o_pixel_flag(pixel_flag),
                            .o_ADC_frame(ADC_frame)
                          );

  signal_selector signal_sel0(
                    .i_phi_r(phi_r),
                    .i_phi_p(phi_p),
                    .i_selector(selector),
                    .o_salida(control_signal)
                  );


endmodule

`default_nettype wire



