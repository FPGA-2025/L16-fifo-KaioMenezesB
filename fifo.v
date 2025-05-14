module fifo(
    input wire clk,
    input wire rstn,
    input wire wr_en,
    input wire rd_en,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    output full,
    output empty
);

    localparam DEPTH = 4;
    localparam ADDR_WIDTH = 2;

    reg [7:0] buffer [0:DEPTH-1];
    reg [ADDR_WIDTH:0] write_ptr = 0;
    reg [ADDR_WIDTH:0] read_ptr = 0;
    wire [ADDR_WIDTH-1:0] write_addr = write_ptr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] read_addr  = read_ptr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH:0] next_write_ptr = write_ptr + 1;

    assign empty = (write_ptr == read_ptr);
    assign full  = (next_write_ptr[ADDR_WIDTH] != read_ptr[ADDR_WIDTH]) &&
                   (next_write_ptr[ADDR_WIDTH-1:0] == read_ptr[ADDR_WIDTH-1:0]);

    always @(posedge clk) begin
        if (!rstn) begin
            read_ptr <= 0;
            data_out <= 8'bx;
        end else if (rd_en && !empty) begin
            data_out <= buffer[read_addr];
            read_ptr <= read_ptr + 1;
        end
    end

    always @(posedge clk) begin
        if (!rstn)
            write_ptr <= 0;
        else if (wr_en && !full) begin
            buffer[write_addr] <= data_in;
            write_ptr <= next_write_ptr;
        end
    end

endmodule