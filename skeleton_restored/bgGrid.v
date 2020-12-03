module bgGrid(
		input [9:0] x, y,
		output backedge
		);
		
		parameter left=239;
		parameter right=401;
		
		assign backedge = (y>=239&&y<=401&&x>=79&&x<=401)&&((y-240)%16==0||x%16==0||y==239||y==401||x==79||x==401) ? 1:0;
		
endmodule
