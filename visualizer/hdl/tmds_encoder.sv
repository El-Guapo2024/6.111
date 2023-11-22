module tmds_encoder(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] data_in,  // video data (red, green or blue)
  input wire [1:0] control_in, //for blue set to {vs,hs}, else will be 0
  input wire ve_in,  // video data enable, to choose between control or video signal
  output logic [9:0] tmds_out
);

  logic [8:0] q_m;
  logic [4:0] tally;
  logic [4:0] number_of_ones;
  logic [4:0] number_of_zeroes;
  //you can assume a functioning (version of tm_choice for you.)
  tm_choice mtm(
    .data_in(data_in),
    .qm_out(q_m));


always_comb begin 
    number_of_ones = 0 ; 
    number_of_zeroes = 0 ;
    for ( int i = 0 ; i < 8 ; i = i+1 )begin
        if(q_m[i] == 1) begin
            number_of_ones = number_of_ones + 1;
        end else begin 
            number_of_zeroes = number_of_zeroes + 1;
        end 
    end 

end

  //your code here.
    always_ff @(posedge clk_in)begin
        if(rst_in) begin 
            tally <= 0 ;
        end else if (ve_in == 0) begin 
            case(control_in)
                2'b00: tmds_out <= 10'b1101010100 ;
                2'b01: tmds_out <= 10'b0010101011 ;
                2'b10: tmds_out <= 10'b0101010100 ;
                2'b11: tmds_out <= 10'b1010101011 ;
            endcase
            tally <= 0 ;
        end else begin 
            if( (tally == 0) || (number_of_ones == number_of_zeroes)) begin
                tmds_out[9] <= ~q_m[8] ;
                tmds_out[8] <= q_m[8] ;
                tmds_out[7:0] <= (q_m[8] ==1) ?  q_m[7:0] : ~q_m[7:0] ;
                if(q_m[8] == 0) begin
                    tally <= tally + (number_of_zeroes-number_of_ones) ;
                end else begin 
                    tally <= tally + (number_of_ones-number_of_zeroes) ;
                end 
            end else begin 
                if (( tally[4] == 0 && number_of_ones > number_of_zeroes) || (tally[4] == 1 && number_of_zeroes > number_of_ones)) begin
                    tmds_out[9] <= 1 ;
                    tmds_out[8] <= q_m[8] ;
                    tmds_out[7:0] <= ~q_m[7:0] ;
                    if(q_m[8] == 0) begin
                        tally <= tally + number_of_zeroes-number_of_ones;
                    end else begin 
                        tally <= tally + (number_of_zeroes-number_of_ones) + 2;
                    end 
                end else begin 
                    tmds_out[9] <= 0 ;
                    tmds_out[8] <= q_m[8] ;
                    tmds_out[7:0] <= q_m[7:0] ;
                    if(q_m[8] == 0) begin
                        tally <= tally - 2 + (number_of_ones-number_of_zeroes) ;
                    end else begin 
                        tally <= tally + (number_of_ones-number_of_zeroes) ;
                    end 
                end
            end 
        end 
    end 


endmodule //end tmds_encoder
