function Data = eqn_readSmosDBL(filename)
% Data = eqn_readSmosDBL(filename)
%
% The function reads an Ocean Salinity User Data Product 
% (OSUDP) data block file (.DBL) from the SMOS mission. 
% It takes as input the filename and gives as output a 
% matlab matrix of doubles with as many rows as there are 
% records in the file and as many columns as there are 
% variables. To understand what each column means, you 
% have to check the documentation file 
%     "eqn_readSmosDBL_Var_Table.pdf" 
% which explains the variables contained in the data 
% file. The column number of a particular variable 
% corresponds to its Field ID number minus one. For 
% example, the Latitude variable has a Field # 03, 
% therefore it will be found in the second column of the 
% resulting matrix. The only is exception to this rule is 
% the first variable (with Field # equal to 01), which is 
% just the number of records in the file and can be 
% derived by measuring the number of rows in the 
% resulting data matrix e.g. by calling size(Data, 1).
% 

fid = fopen(filename, 'r', 'l');

N_Grid_Points = fread(fid, 1, 'uint32', 0);

Data = nan(N_Grid_Points, 64);
% Grid_point_Data = nan(N_Grid_Points, 3);
% Geophysical_Parameters_Data = nan(N_Grid_Points, 22);
% Control_Flags = nan(N_Grid_Points, 4);
% Product_Confidence_Descriptor = nan(N_Grid_Points, 30);
% Science_Flags = nan(N_Grid_Points, 4);
% Science_Descriptors = nan(N_Grid_Points, 1);

for i=1:N_Grid_Points    
    % Grid_Point_Data set record structure
    id = fread(fid, 1, 'uint32', 0);
    lat = fread(fid, 1, 'float32', 0);
    lon = fread(fid, 1, 'float32', 0);

%    Grid_point_Data(i,1) = double(id);
%    Grid_point_Data(i,2:3) = [lat, lon];
    
    % Geophysical_Parameters_Data structure
    geo_phys_data = fread(fid, 22, 'float32', 0);
%    Geophysical_Parameters_Data(i,:) = geo_phys_data';
    
    % Control_ Flags structure
    flags = fread(fid, 4, 'uint32', 0);
%    Control_Flags(i,:) = double(flags');
    
    % Product_Confidence_Descriptor structure
    conf_1 = fread(fid, 12, 'uint16', 0);
    conf_2 = fread(fid, 4, 'uint8', 0);
    conf_3 = fread(fid, 14, 'uint16', 0);
%    Product_Confidence_Descriptor(i,:) = double([conf_1;conf_2;conf_3]');
    
    % Science_Flags structure
    sci = fread(fid, 4, 'uint32', 0);
%    Science_Flags(i,:) = double(sci');
    
    % Science_Descriptors structure
    Dg_sky = fread(fid, 1, 'uint16', 0);
%    Science_Descriptors(i) = double(Dg_sky);
    
    % copy all to Data matrix
    Data(i,:) = double([id;lat;lon;geo_phys_data;flags;conf_1;conf_2;conf_3;sci;Dg_sky]');
end

fclose(fid);

end