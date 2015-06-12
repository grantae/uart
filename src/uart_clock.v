`timescale 1ns / 1ps
/*
 * File         : uart_clock.v
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
 *   Generate synchronous pulses for 115200 baud and 16x 115200 baud (synchronized)
 *   from an uncorrelated input clock.
 *
 *   This timing can be adjusted to allow for other baud rates.
 */
module uart_clock(
    input clock,
    output uart_tick,
    output uart_tick_16x
    );

    /* Goal: Generate a pulse at 115200 Hz using an input clock
     * that is not an even multiple of 115200.
     *
     * Method: Find constants 'a', 'b' such that clock / (2^a / b) ~= 115200.
     * Accumulate 'b' each cycle and use the overflow bit 'a' for the pulse.
     *
     * 66  MHz:  66 MHz / (2^18 / 453) = 115203.857 Hz
     * 100 MHz: 100 MHz / (2^17 / 151) = 115203.857 Hz
     *
     * We also need to extend this for a 16x pulse to over-sample:
     *
     * 66  MHz:  66 MHz / (2^14 / 453) = 115203.857 Hz * 16
     * 100 MHz: 100 MHz / (2^13 / 151) = 115203.857 Hz * 16
     */

    // 16x Pulse Generation

    // 66 MHz version
    reg [14:0] accumulator = 15'h0000;
    always @(posedge clock) begin
        accumulator <= accumulator[13:0] + 453;
    end
    assign uart_tick_16x = accumulator[14];

/*
    // 100 MHz version
    reg [13:0] accumulator = 14'h0000;
    always @(posedge clock) begin
        accumulator <= accumulator[12:0] + 151;
    end
    assign uart_tick_16x = accumulator[13];
*/

    // 1x Pulse Generation (115200 Hz)
    reg [3:0] uart_16x_count = 4'h0;
    always @(posedge clock) begin
        uart_16x_count <= (uart_tick_16x) ? uart_16x_count + 1'b1 : uart_16x_count;
    end
    assign uart_tick = (uart_tick_16x==1'b1 && (uart_16x_count == 4'b1111));

endmodule
