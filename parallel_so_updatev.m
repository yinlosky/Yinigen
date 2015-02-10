%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name:parallel_so_updatev
%% Function: This is internal function for parallel_selective_orthogonalize.m to calculate 'lz_vpath' = 'lz_vpath' - 'so_rrtv'
%%
%% Author: Yin Huang
%% Date: Dec 11, 2014

myDB; %% connect to DB and return a binding named DB.

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');

parallel_so_v = DB('lz_vpath');
%parallel_so_rrtv = DB('so_rrtv'); This cause the bug because parallel_so_rrtv is file name

p_so_rrtv=DB('so_rrtv');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));


disp(['Calcuating lz_vpath = lz_vpath - so_rrtv' ]);
	gap = floor(NumOfNodes / NumOfMachines);
	w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
	myMachine = global_ind(w); %Parallel

	for i = myMachine
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

		valVector = [];
		for j = start_node:end_node  
		% j is the row_id for the vector! We need to set Output = y - x*alph  
		% y = str2num(Val(y(sprintf('%d,',j),'1,'))); 
		% x = str2num(Val(x(sprintf('%d,',j),'1,')));
		% newV = y - x * alph;
		% newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newV));
		% put(output,newAssoc);
		%% This operation might need optimization 
     	        if(~isempty(parallel_so_v(sprintf('%d,',j),'1,')))	
     		vv = str2num(Val(parallel_so_v(sprintf('%d,',j),'1,')));
		else
		vv = 0;
		end
		if(~isempty(p_so_rrtv(sprintf('%d,',j),'1,')))
		vrrtv = str2num(Val(p_so_rrtv(sprintf('%d,',j),'1,')));
		else
		vrrtv = 0;
		end
     		newV = vv - vrrtv;
		valVector(size(valVector,2)+1) = newV;
     	%	newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',newV));
     	%	put(parallel_so_v,newAssoc);
		end	
		put(parallel_so_v,Assoc(sprintf('%d,',start_node:end_node),'1,',sprintf('%.15f,',valVector)));
	end
agg(w);

