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

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "rtl/user_analog_project_wrapper.v"
    `include "rtl/signal_generator.v"
    `include "rtl/adc_module.v"
    `include "rtl/analog_signal_generator.v"
`else
    `include "user_analog_project_wrapper.v"
    `include "designs_wrapper.v"
    `include "signal_generator.v"
    `include "adc_module.v"
    `include "analog_signal_generator.v"
    `include "buffer_analog.v"
`endif
