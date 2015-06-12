`timescale 1ns / 1ps
/*
 * File         : RAM_SP_AR.v
 * Project      : XUM MIPS32
 * Creator(s)   : Grant Ayers (ayers@cs.stanford.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   6-Nov-2014   GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A simple write-first memory of configurable width and
 *   depth, made to be inferred as a Xilinx Block RAM (BRAM).
 *
 *   SP-> Single-port.
 *   AR-> Asynchronous (combinatorial) read
 *
 *   Read data is available on the same cycle.
 */

module RAM_SP_AR(clk, addr, we, din, dout);
    parameter  DATA_WIDTH = 8;
    parameter  ADDR_WIDTH = 8;
    localparam RAM_DEPTH  = 1 << ADDR_WIDTH;
    input  clk;
    input  [(ADDR_WIDTH-1):0] addr;
    input  we;
    input  [(DATA_WIDTH-1):0] din;
    output [(DATA_WIDTH-1):0] dout;

    reg [(DATA_WIDTH-1):0] ram [0:(RAM_DEPTH-1)];

    assign dout = ram[addr];

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= din;
        end
    end

endmodule
