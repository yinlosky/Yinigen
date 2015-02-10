%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name:parallel_mv_p2.m
%% Function: p2 of parallel matrix 'InputMatrix' multiply the vector (lz_q{i}), this function will read data from 'mv_temp' and write result in 'lz_vpath' 
%%
%%

myDB; %% connect to DB and return a binding named DB.
machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');
cur_it = DB('cur_it');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));
vector = ['lz_q' num2str(str2num(Val(cur_it('1,','1,'))))];

disp(['!!!!!!!Now running matrix multiply the vector ' vector ' P2 !!!!!!!!!!!!!']);
disp(['********matrix: mv_temp ************']);

temp = DB('mv_temp'); %%hard coded temporary output table
output = DB('lz_vpath');


gap = floor(NumOfNodes / NumOfMachines);

myMachine = 1:NumOfMachines;
w = zeros(NumOfMachines,1,map([Np 1],{},0:Np-1));
myMachine = global_ind(w); %Parallel
%% We will sum all rows into the vector, if one row is empty we simply add 0 to the row to avoid mistaken value for the next step vi' * v 
for i = myMachine
        start_node = (i-1)*gap+1;
	if (i<NumOfMachines)
	end_node = i*gap ;
	else 
	end_node = NumOfNodes ;
	end
	disp(['start index: ' num2str(start_node) ' end index: ' num2str(end_node)]);

	for j = start_node:end_node  % j is the row_id for the matrix! We need to sum the elements in the same row. 
        [row,col,val]= temp(sprintf('%d,',j),:);
       
	if( ~isempty(val))
	val = str2num(val);
	mysum = sum(val);
	newAssoc = Assoc(sprintf('%d,',j),'1,',sprintf('%.15f,',mysum));
	put(output,newAssoc);
	else
	put(output,Assoc(sprintf('%d,',j),'1,','0,'));
	end
	end
 end
agg(w);

