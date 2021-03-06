%%%%function Rpath = computeR(row,col,Q, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: parallel_computeR.m
%This is internal function for parallel_selective_orthogonalize.m to compute the vector r 
%% r <-- V-row * Q[:,col] Q is the eigenVector matrix, Vi should be reading from lz_q{i} tables
%	Q
%
%
%
%% Output: r should be a n*1 vector and stored in r table
%% Input: 1.row is the number to determing the number of tables to read from lz_q
%%        2.col determines the Q's column index   
%%        3.Q is the right vector for multiplication
%%        4.NumOfNodes is the dimension of V: nx1
%%        5.NumOfMachines for parallization

format long;
myDB;
R_output_table = 'so_rpath';
R_output = DB(R_output_table);

cur_it_t = DB('cur_it');
cur_loop_j = DB('cur_loop_j');
alpha_table = DB('alpha');
beta_table = DB('beta');
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');

row = str2num(Val(cur_it_t('1,','1,')));
col = str2num(Val(cur_loop_j('1,','1,')));
NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));


for temp_ind = 1:row
   alpha_arr(1,temp_ind) = str2num(Val(alpha_table(sprintf('%d,',temp_ind),:)));
end


main_diag = alpha_arr;
if(row<2)
	R_Tmatrix = diag(main_diag);
else
	main_diag = alpha_arr;
	for temp_ind = 1:row-1
	beta_arr(1,temp_ind) = str2num(Val(beta_table(sprintf('%d,',temp_ind),:)));
	end
	off_diag = beta_arr;
	R_Tmatrix = diag(main_diag) + diag(off_diag,1) + diag(off_diag,-1);

end

[myQ, myD] = eig(R_Tmatrix);


%%%%%%%%%%%%%%Below is to get the matrix from lz_q{1:row}
v_prefix = ([num2str(NumOfNodes) 'lz_q']);   %% v_prefix is lz_q to retrieve the tables named from lz_q{1:row}
table_names = cell(row,1);
for i = 1:row
	table_names{i} = [v_prefix num2str(i)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tables = cell(row,1);
for i = 1:row
	tables{i} = DB(table_names{i});
end



gap = floor(NumOfNodes / NumOfMachines);
%global sum=0;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First split the reading from the input table, and calculate the norm(result)^2 and written to local results 
%% Later, all local results are summed up and sqr root for the final norm.
%%
%%  
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
%%% Above is for splitting the rows of the matrix v
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%             Tyring to optimize, however, if lz_q{i} table has empty elements, this will fail because the tableV will destroy the value sequence. 
%	resultV = 0;
%   for k = 1: row
%	v_k = myQ(k,col);  %v_k is a scalar value
%	table = tables{k};
%	[tableR,tableC,tableV] = table(sprintf('%d,',start_node:end_node),:);
%	m_k = str2num(tableV); 
%	resultV = resultV + m_k * v_k;


%**********************************Old Code************************
%%   ( m_k )
%%   (  j  ) *  k loop value and then sum them up
%%   (  j  )
%%   ( m_k )
%%
	valVector=[];
     for j = start_node:end_node  % j is the row id for output
	row_sum = 0;
        for k = 1:row             % k is the matrix row iterator id we need read elements from lz_q{1:row} also k is the row id for vector Q	
           v_k = myQ(k,col);	  % v_k is the k-th row from col-th column of Q; v_k will multiply j-th row from lz_q{1:row}
	   table = tables{k};
		if(~isempty(table(sprintf('%d,',j),'1,')))
           m_k = str2num(Val(table(sprintf('%d,',j),'1,')));
		else
		m_k=0;
		end 
	   row_sum = row_sum + v_k*m_k;
	end
%	outAssoc = Assoc(sprintf('%d,',j),'1,', sprintf('%.15f,',row_sum));
%	put(R_output, outAssoc);   %% construct the result and store in the output table 'so_rpath'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Old approach write one by one, we optimize by construting final string to add
	valVector(size(valVector,2)+1) =row_sum;  
	
    end
	put(R_output,Assoc(sprintf('%d,',start_node:end_node),'1,',sprintf('%.15f,',valVector)));
end
agg(w);

%*******************************************************************88
	









