%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File Name: parallel_rtv_p1.m
%% Function: this is internal function for parallel_selective_orthogonalize.m to compute the rtv parallelly p1 the intermidiate result saved in 'rtv_temp'
%%  p2 will read from rtv_temp and write the result in 'scalar_rtv'.
%%% rtv = dotproduct('so_rpath', 'lz_vpath', NumOfNodes, NumOfMachines);
% scalar_rtv is the dotproduct and saved in 'scalar_rtv' table from parallel_rtv

disp('Computing rtv in parallel...rtv = dotproduct(so_rpath,lz_vpath,numofnodes, numofmachines)');

myDB;

machines_t = DB('NumOfMachines');
nodes_t = DB('NumOfNodes');

NumOfMachines = str2num(Val(machines_t('1,','1,')));
NumOfNodes = str2num(Val(nodes_t('1,','1,')));

p_rtv_temp = DB('rtv_temp');

v = DB('so_rpath'); 
vi = DB([num2str(NumOfNodes) 'lz_vpath']);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Two approaches for this embarassing parallel job, one is to multiply one pair once and then sum them up, the other is use iterator 
% Not sure which is faster!!! For now I am taking the first approach.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp_sum = 0;
for j = start_node:end_node  % j is the row_id for the vector! We need to multiply the element from the same row_id. 
		if(~isempty(v(sprintf('%d,',j),'1,')))
			x = str2num(Val(v(sprintf('%d,',j),'1,')));
		else 
			x = 0;
		end
		if(~isempty(vi(sprintf('%d,',j),'1,')))
			y = str2num(Val(vi(sprintf('%d,',j),'1,')));
		else
			y = 0;
		end
	temp_sum = temp_sum + x * y;
end 
  newAssoc = Assoc(sprintf('%d,',i),'1,',sprintf('%.15f,',temp_sum));
  put(p_rtv_temp,newAssoc);
end 
agg(w);
