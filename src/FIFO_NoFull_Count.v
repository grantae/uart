`timescale 1ns / 1ps
/*
 * File         : FIFO_NoFull_Count.v
 * Creator(s)   : Grant Ayers (ayers@cs.stanford.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   24-May-2010  GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   A synchronous FIFO of variable data width and depth. 'enQ' is ignored when
 *   the FIFO is full and 'deQ' is ignored when the FIFO is empty. If 'enQ' and
 *   'deQ' are asserted simultaneously, the FIFO is unchanged and the output data
 *   is the same as the input data.
 *
 *   This FIFO is "First word fall-through" meaning data can be read without
 *   asserting 'deQ' by merely supplying an address. This data is only valid
 *   when not writing and not empty (i.e., valid when ~(empty | enQ)).
 *   When 'deQ' is asserted, the data is "removed" from the FIFO and one location
 *   is freed.
 *
 * Variation:
 *   - There is no output to indicate the FIFO is full.
 *   - Output 'count' indicates how many elements are in the FIFO, from 0 to 256
 *     (for 8-bit ADDR_WIDTH).
 */
module FIFO_NoFull_Count(clock, reset, enQ, deQ, data_in, data_out, empty, count);
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 8;
    parameter RAM_DEPTH = 1 << ADDR_WIDTH;
    input clock;
    input reset;
    input enQ;
    input deQ;
    input  [(DATA_WIDTH-1):0] data_in;
    output [(DATA_WIDTH-1):0] data_out;
    output empty;
    output reg [(ADDR_WIDTH):0] count;          // How many elements are in the FIFO (0->256)

    reg  [(ADDR_WIDTH-1):0] enQ_ptr, deQ_ptr;   // Addresses for reading from and writing to internal memory
    wire [(ADDR_WIDTH-1):0] addr = (enQ) ? enQ_ptr : deQ_ptr;

    assign empty = (count == 0);
    wire full = (count == (1 << ADDR_WIDTH));

    wire [(DATA_WIDTH-1):0] w_data_out;
    assign data_out = (enQ & deQ) ? data_in : w_data_out;

    wire w_enQ = enQ & ~(full  | deQ);           // Mask 'enQ' when the FIFO is full or reading
    wire w_deQ = deQ & ~(empty | enQ);           // Mask 'deQ' when the FIFO is empty or writing

    always @(posedge clock) begin
        if (reset) begin
            enQ_ptr <= 0;
            deQ_ptr <= 0;
            count <= 0;
        end
        else begin
            enQ_ptr <= (w_enQ) ? enQ_ptr + 1'b1 : enQ_ptr;
            deQ_ptr <= (w_deQ) ? deQ_ptr + 1'b1 : deQ_ptr;
            count <= (w_enQ ~^ w_deQ) ? count : ((w_enQ) ? count + 1'b1 : count - 1'b1);
        end
    end

    RAM_SP_AR #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
        ram(
        .clk  (clock),
        .addr (addr),
        .we   (w_enQ),
        .din  (data_in),
        .dout (w_data_out)
    );

endmodule
