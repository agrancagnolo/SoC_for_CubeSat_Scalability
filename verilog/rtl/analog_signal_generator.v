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

`timescale 1ns/1ps

module analog_signal_generator (
    input wire      i_enable,
    input wire      i_phi_l2,
    input wire      i_phi_p,
    output reg      o_adc_start_convertion
);

reg [2:0] contador_flancos;
reg o_pixel_flag;

always @(negedge i_phi_l2 or posedge i_phi_p) begin
    if (i_phi_p)
        contador_flancos <= 0;
    else if (i_enable)
        contador_flancos <= contador_flancos + 1;
end

always @(negedge i_phi_l2) begin
    o_pixel_flag <= (contador_flancos == 5);
    if(i_phi_l2) begin
        o_adc_start_convertion <= 0;
    end else begin
        o_adc_start_convertion <= o_pixel_flag;
    end
end

endmodule

`default_nettype wire



