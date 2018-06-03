module isfinger(
	input [8:0] q,
	output wire is_finger
);
	assign is_finger = q[5:3] > 2 && !q[8] && !q[2];
endmodule
