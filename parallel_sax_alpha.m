%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: parallel_sax_alpha.m
%% Function: This function will calculate alpha_i * v_i
%% 			alpha is the table 'alpha_t';
%% 			v is the table 'lz_q'
%% 			i is read from table 'cur_it'
%%	     Output in 'alpha_sax_temp'
%% Author: Yin Huang
%% Date: Dec 11, 2014

myDB; %% connect to DB and return a binding named DB.
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
it = str2num(Val(cur_it('1,','1,')));
    
vector = [num2str(NumOfNodes) 'lz_q' num2str(it)];
parallel_sax_alpha_v_t = DB(vector);  %% v_i

parallel_sax_alpha_alpha_t = DB('alpha');

parallel_sax_alpha_output = DB('alpha_sax_temp');

[alphaR,alphaC,alphaV]= parallel_sax_alpha_alpha_t(sprintf('%d,',it),:);
if (isempty(alphaV)) 
	parallel_sax_alpha_value = 0;
else
	parallel_sax_alpha_value = str2num(alphaV);
end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parallel part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	disp(['Calcuating ' num2str(parallel_sax_alpha_value) ' times vector: ' vector ]);
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
	
	[vectorRow,vectorCol,vectorVal] = parallel_sax_alpha_v_t(sprintf('%d,',start_node:end_node),:);
	if(~isempty(vectorVal))
		vectorVal = str2num(vectorVal);
	else
		vectorVal = 0;
	end

	vectorVal = vectorVal * parallel_sax_alpha_value; %vector_i * alpha_i
	valStr = sprintf('%.15f,',vectorVal);
	rowStr = sprintf('%d,',str2num(vectorRow));
    colStr = sprintf('%d,',str2num(vectorCol));
        put(parallel_sax_alpha_output,Assoc(rowStr,colStr,valStr));

	
	end
	agg(w);

