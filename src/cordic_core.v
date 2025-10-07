module cordic_core (
    input  wire         clk,
    input  wire         rst,
    input  wire         bus_write,
    input  wire         bus_read,
    input  wire [5:0]   addr,
    input  wire [31:0]  wdata,
    output reg  [31:0]  rdata,
    output reg          done
);

    parameter WIDTH = 16;      // fixed-point width
    parameter ITER  = 16;      // number of CORDIC iterations

    // Registers
    reg signed [WIDTH-1:0] x, y;
    reg signed [31:0]       z;
    reg [4:0]               iter_cnt;
    reg                     busy;

    // CORDIC arctangent table (precomputed)
    reg [31:0] atan_table [0:ITER-1];
    integer i;

    initial begin
        atan_table[0]  = 32'b00100000000000000000000000000000;
        atan_table[1]  = 32'b00010010111001000000010100011101;
        atan_table[2]  = 32'b00001001111110110011100001011011;
        atan_table[3]  = 32'b00000101000100010001000111010100;
        atan_table[4]  = 32'b00000010100010110000110101000011;
        atan_table[5]  = 32'b00000001010001011101011111100001;
        atan_table[6]  = 32'b00000000101000101111011000011110;
        atan_table[7]  = 32'b00000000010100010111110001010101;
        atan_table[8]  = 32'b00000000001010001011111001010011;
        atan_table[9]  = 32'b00000000000101000101111100101110;
        atan_table[10] = 32'b00000000000010100010111110011000;
        atan_table[11] = 32'b00000000000001010001011111001100;
        atan_table[12] = 32'b00000000000000101000101111100110;
        atan_table[13] = 32'b00000000000000010100010111110011;
        atan_table[14] = 32'b00000000000000001010001011111001;
        atan_table[15] = 32'b00000000000000000101000101111100;
    end

    // Bus-mapped register addresses
    localparam ADDR_CTRL  = 6'h00;
    localparam ADDR_ANGLE = 6'h04;
    localparam ADDR_COS   = 6'h08;
    localparam ADDR_SIN   = 6'h0C;

    // Combined state machine
    always @(posedge clk) begin
        if (rst) begin
            busy     <= 0;
            done     <= 0;
            iter_cnt <= 0;
            x        <= 0;
            y        <= 0;
            z        <= 0;
        end else begin
            // Default: clear done flag after one cycle
            if (done && !bus_write) begin
                done <= 0;
            end
            
            // Bus write - start new computation
            if (bus_write && addr == ADDR_ANGLE) begin
                z        <= wdata;
                x        <= 16'd23170; // K fixed-point scaling ~0.607*2^15
                y        <= 0;
                iter_cnt <= 0;
                busy     <= 1;
                done     <= 0;
            end 
            // CORDIC iteration
            else if (busy) begin
                // Perform rotation
                if (z[31] == 0) begin
                    x <= x - (y >>> iter_cnt);
                    y <= y + (x >>> iter_cnt);
                    z <= z - atan_table[iter_cnt];
                end else begin
                    x <= x + (y >>> iter_cnt);
                    y <= y - (x >>> iter_cnt);
                    z <= z + atan_table[iter_cnt];
                end

                // Check if done
                if (iter_cnt == ITER-1) begin
                    busy     <= 0;
                    done     <= 1;
                    iter_cnt <= 0;
                end else begin
                    iter_cnt <= iter_cnt + 1;
                end
            end
        end
    end

    // Bus read logic (combinational)
    always @(*) begin
        case(addr)
            ADDR_CTRL:  rdata = {31'b0, done};
            ADDR_COS:   rdata = {{16{x[WIDTH-1]}}, x}; // sign-extend
            ADDR_SIN:   rdata = {{16{y[WIDTH-1]}}, y}; // sign-extend
            default:    rdata = 32'b0;
        endcase
    end

endmodule