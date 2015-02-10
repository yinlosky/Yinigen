function y=Write_BAssoc(NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%File name: Write_BAssoc.m
%%This function is used to generate the initial vector B in parallel
%%Input:(para3)
%%	para3: number of nodes for parallelization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Below parameters are for splitting the file into different parts 

%%%%

myMachine = 1: NumOfMachines;
%myMachine = global_ind(zeros(myMachine,1,map([Np 1],{},0:Np-1))); %Parallel
for i = myMachine
	tic;
	fname = ['B/' num2str(i)]; disp(fname);
        
	fidRow = fopen([fname 'r.txt'],'r+');
	%fidVal = fopen([fname 'v.txt'],'r+');
	fidCol = fopen([fname 'c.txt'],'r+');
	
	colStr = fread(fidCol,inf,'uint8=>char').';
	rowStr = fread(fidRow,inf,'uint8=>char').';
	valStr = sprintf('%.15f,',textread([fname 'v.txt'],'%f','delimiter',','));
	
	fclose(fidRow);  fclose(fidCol);
	A = Assoc(rowStr,colStr,valStr,@min);
	save([fname '.mat'],'A');
	assocTime =toc;
	disp(['Time: ' num2str(assocTime) ', Edges/sec: ' num2str(NumStr(rowStr)./assocTime)]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    int gap = number_nodes / nmachines;
%% 
%%   String file_name = "lanczos.initial_b.temp";
%%    FileWriter file = new FileWriter(file_name);
%%    BufferedWriter out = new BufferedWriter(file);
%%    out.write("# number of nodes in graph = " + number_nodes + "\n");
%%    System.out.println("creating initial b vector (total nodes = " + number_nodes + ")");

 %%   for (int i = 0; i < nmachines; i++)
 %%   {
 %%     int start_node = i * gap;
 %%     int end_node;
 %%     int end_node;
 %%     if (i < nmachines - 1)
 %%       end_node = (i + 1) * gap - 1;
 %%     else {
 %%       end_node = number_nodes - 1;
 %%     }
 %%     out.write("" + i + "\t" + start_node + "\t" + end_node + "\n");
 %%   }
 %%   out.close();

 %%   FileSystem fs = FileSystem.get(getConf());
 %%   fs.copyFromLocalFile(true, new Path("./" + file_name), new Path(initial_input_path.toString() + "/" + file_name));
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
end