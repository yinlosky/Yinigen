%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name:parallel_lz_norm_v_p1.m
%% Function: This is p1 to calculate the norm of the 'lz_vpath'
%%
%% Author: Yin Huang
%% Date: Dec, 11, 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize the tables 
myDB;
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');


NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% variables defintion %%%%%%%%%%%%%%%%%%%%%%%%%

Input_table = ([num2str(NumOfNodes) 'lz_vpath']);   % local variable hard coded.
norm_v_temp = (['lz_norm_v' num2str(NumOfNodes) '_temp']); % local variable for temp table, temp table will be read for p2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InputT = DB(Input_table); % create a database binding to the input table.
norm_v_temp = DB(norm_v_temp); % create a database binding to the temp table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Parallel read the input_table, and set the range for each reader, each reader will write the sum of sqr in a local directory called lz_norm/iv.txt(i is the id of each reader)

gap = floor(NumOfNodes / NumOfMachines);

myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First split the reading from the input table, and calculate the norm(result)^2 and written to local results 
%% Later, all local results are summed up and sqr root for the final norm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = myMachine

        start_node = (i-1)*gap+1;
		if (i<NumOfMachines)
			end_node = i*gap ;
		else 
			end_node = NumOfNodes ;
		end
	length = end_node - start_node+1;
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node) 'length: ' num2str(length)]);
	
	
	queryRange = sprintf('%d,',start_node:end_node);
	tempStr=Val(InputT(queryRange,:));
	res = cell2mat(textscan(tempStr,'%.15f','Delimiter','\n')); %% textscan will read well-formatted data into a cell array with new line as delimiter; the result will be transfered into a matrix
	tempSum = norm(res)^2;  %% This is the norm(result)^2. tempSum is to be written on local temp file 
	
	valStr = sprintf('%.15f,', tempSum);
	disp(['Result in ' num2str(i) ' th processor is ' valStr]);
	resultAssoc = Assoc(sprintf('%d,',i),'1,',valStr);
	put(norm_v_temp, resultAssoc);
end
agg(w); %% wait for processors to finish all the work! This could possibly optimze for performance!!!
