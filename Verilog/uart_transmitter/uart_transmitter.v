module uart_transmitter (
    input wire [7:0]data,
    input wire baud_rate_signal,
    input wire start,
    input wire rst,
    input wire clk,
    output reg uart_tx
);

parameter idle = 0;
parameter transmit = 1;
reg [9:0]d;

reg [3:0]bit_counter = 0;
reg state = idle;

reg [3:0]next_bit_counter;
reg next_state;
reg uart_tx_local;

//input data
always @(*) begin
    if (start == 1) begin
        d = {1'b1, data, 1'b0};
    end else begin
        d = 0;
    end
end


//state transition
always @(*) begin
    case (state)
    idle: begin
        if (start == 1) begin
            next_state = transmit;
            uart_tx_local = 1;
            next_bit_counter = 0;
        end else begin
            next_state = idle;
            uart_tx_local = 1;
            next_bit_counter = 4'd0;
        end  
    end
    transmit: begin
        if (baud_rate_signal == 1) begin
            if (bit_counter == 4'd9) begin
                next_state = idle;
                uart_tx_local = 1;
                next_bit_counter = 4'd0;
            end else begin
                next_state = transmit;
                uart_tx_local = d[bit_counter];
                next_bit_counter = bit_counter + 1;
            end  
        end else begin
            if (bit_counter == 0) begin
                uart_tx_local = 1;
            end else begin //keep transmit the previous d
                uart_tx_local = d[bit_counter - 1];
            end
            next_state = transmit;
            next_bit_counter = bit_counter; 
        end  
    end 
    endcase
end


always @(posedge clk) begin
    if (rst) begin
        state <= idle;
        bit_counter <= 4'b0;
        uart_tx <= 1;
    end else begin
        state <= next_state;
        bit_counter <= next_bit_counter;
        uart_tx <= uart_tx_local;
    end
        
end


endmodule //uart_transmitter