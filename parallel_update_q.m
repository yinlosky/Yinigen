%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: parallel_update_q.m
%% Function: lz_q{it+1} =  lz_vpath * (1/beta_it)
%% Input:
%%	it should be read from 'cur_it ('1,','1,') '
%% 	lz_vpath should be read from 'lz_vpath'
%% 	beta should be read from 'beta('it,','1,')'
%%
%% Author: Yin Huang
%% Date: Dec 11,2014

myDB;
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');
it = str2num(Val(cur_it('1,','1,')));


update_lz_vpath = DB([num2str(NumOfNodes)'lz_vpath']);
update_q_beta_t = DB('beta');


NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));


update_q_output = DB([num2str(NumOfNodes)'lz_q' num2str(it+1)]);
if(~isempty(update_q_beta_t(sprintf('%d,',it),'1,')))
beta_it_v = str2num(Val(update_q_beta_t(sprintf('%d,',it),'1,')));
beta_it_v = 1./beta_it_v;
else
beta_it_v = 0;
end

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
	disp(['Iteration ' num2str(it) ' beta ' num2str(beta_it_v) ' times lz_vpath' ]);
	%% Below for loop will make sure the 0 values will be written to the table,
	% We need fill with 0s to make sure our query will return the same sequence of value to calculate v = v- sax_alpha_temp - sax_beta_temp
		valVector = [];
		for j = start_node:end_node  
		
     		if(~isempty(update_lz_vpath(sprintf('%d,',j),'1,')))
     			vx = str2num(Val(update_lz_vpath(sprintf('%d,',j),'1,')));
			else
				vx = 0;
			end
		
     		newV = vx * beta_it_v;
			valVector(size(valVector,2)+1) = newV;
		end	
		put(update_q_output,Assoc(sprintf('%d,',start_node:end_node),'1,',sprintf('%.15f,',valVector)));
	end
	agg(w);
