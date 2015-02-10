function Number = selective_orthogonalize(k, beta_i, v_path, Q, D, NumOfNodes, NumOfMachines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% File name: selective_orthogonalize.m
%% This is the function for deciding if an orthogonalization is needed, return the count of orthogonalizations
%% This is a light function, which can be done in a single node.
%% Input:  
%%   	para1: k, the number of iteration
%% 	para2: beta_i, the ith element in beta
%%	para3: vector V name (V in our algorithm)
%%	para4: path of Q (Q is the decomposed eigenvectors)
%%      para5: path of D (D is the decomposed eigenvalues)
%% Output: 
%%	How many times to orthogonalize 
%% Besides if reorthogonalize, r will be written to table r_path, and v will be updated 
%%
%% Author: Yin Huang
%% Date: Nov,30,2014
%%
disp(['!!!!!!!Now running so !!!!!!!!!!!!!']);

myDB;
v = DB(v_path); 

eps = 2.204e-16;
reortho_count = 0;

error_bound = abs(sqrt(eps)*D(k));

for j = 1:k
	cur_error = abs(beta_i * Q(k,j));
	disp(['Error of' num2str(j) '/' num2str(k) ' th vector:' num2str(cur_error)]);
	if(cur_error <= error_bound)
		disp(['V need to be reorthogalized by ' num2str(j) 'th Ritz Vector']);
	reortho_count =  reortho_count + 1;
		disp(['Reorthogonalizing against' num2str(j) 'th Ritz vector']);
% write a method to compute r r = V[i,:]*Q[:,j] computR.m
		
		rpath = computeR(k,j,Q, NumOfNodes, NumOfMachines); %% k is the cur_it value, j is current loop id, Q is the eigenVector matrix constructed from T
		rtv = dotproduct(rpath, v_path, NumOfNodes, NumOfMachines);
		p = saxpy(v_path, rpath, rtv, NumOfNodes, NumOfMachines);
		oldpath = DB(p);
		new_path = DB(v_path);
		delete(new_path);
		rename(oldpath,v_path);
	end
end
	        
Number = reortho_count;


end




