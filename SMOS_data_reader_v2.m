% SMOS_data_reader

apprRecordsPerFile = 20000;
nVars = 8;
% set direction to 'DESCENDING', 'DESCENDING' or 'ALL'
DIRECTION = 'ASCENDING';
% PATH = ['G:\DATA\SMOS\', DIRECTION, '\'];
% PATH = ['G:\DATA\SMOS\ALL\'];
PATH = 'G:\DATA\SMOS\ftp_request_olga\';
OUT_PATH = 'G:\PROCESSED\SMOS\MEDITERRANEAN_PREORDER\';
TEMP_PATH = 'G:\TEMP\';

D = dir([PATH, '*.DBL']);
nFiles = size(D,1);

% lat_lims = [30.37, 48.7];
% lon_lims = [-8.5,  43.17];
lat_lims = [-90, 90];
lon_lims = [-180, 180];

dateRange = (datenum(2012,1,1):1:datenum(2015,3,16))';
nDays = length(dateRange);
apprFilesPerDay = 5;

% initialize buffers to hold data
data = nan(nDays*apprFilesPerDay*apprRecordsPerFile, nVars);
dataInd = 0;
filenameList = cell(nDays*apprFilesPerDay, 1);
filenameListInd = 0;
delete([TEMP_PATH, '*']);

for i=1:nDays
    v = datevec(dateRange(i));
    yyyy = num2str(v(1),'%04d');
    mm = num2str(v(2),'%02d');
    dd = num2str(v(3),'%02d');
    %dirPath = fullfile(PATH, yyyy, mm, dd);
    dirPath = PATH;
    D = dir([dirPath, filesep, 'SM_*_MIR_OSUDP2_', yyyy, mm, dd, '*.zip']);
    nFiles = length(D);
    
    for j=1:nFiles
        filenameCell = regexp(D(j).name, '(.+)\.zip', 'tokens');
        filenameNoExt = filenameCell{1}{1};
        unzip([dirPath, filesep, D(j).name], TEMP_PATH);
        buffer = eqn_readSmosDBLx([fullfile(TEMP_PATH, filenameNoExt, filenameNoExt), '.DBL']);
        
        % find flagged (FLAG_VALUE = -999)
        f = all(buffer(:, 5:end) < -990, 2);
        buffer = buffer(~f, :);
        if ~isempty(buffer)
            % check ascending/descending path
            % first time index
            [minT, minTind] = min(buffer(:,4));
            % last time index
            [maxT, maxTind] = max(buffer(:,4));
            if buffer(maxTind, 2) > buffer(minTind, 2)
                satPass = 'ASCENDING';
            elseif buffer(maxTind, 2) < buffer(minTind, 2)
                satPass = 'DESCENDING';
            else
                 satPass = 'STATIONARY';
            end
            
            % check no of points within prescribed geographical limits
            fi = find(buffer(:,2) >= lat_lims(1) & buffer(:,2) <= lat_lims(2) & ...
                    buffer(:,3) >= lon_lims(1) & buffer(:,3) <= lon_lims(2));
            
            buffer = buffer(fi, :);
            if ~isempty(buffer) && (strcmp(DIRECTION, satPass) || strcmp(DIRECTION, 'ALL'))
                sb = size(buffer, 1);
                data(dataInd+1:dataInd+sb, :) = buffer;
                dataInd = dataInd + sb;
                
                filenameList{filenameListInd + 1} = filenameNoExt;
                filenameListInd = filenameListInd + 1;
            end
        end
        rmdir(fullfile(TEMP_PATH, filenameNoExt), 's');
    end
end

% clear unused entries in data matrix
data(dataInd+1:end, :) = [];
filenameList(filenameListInd + 1:end) = [];

% convert time to MATLAB format
data(1:dataInd,4) = data(1:dataInd,4) + datenum(2000,1,1);

% save the list of filenames as well. This way, if a new dataset emerges
% you can easily check if it has been processed into the 'data' matrix or
% not.
save([OUT_PATH, 'SMOS_', DIRECTION(1:3),'_v1.mat'], 'data', 'filenameList', '-v7.3');

%% Grid-point Time Series

if ~exist('data', 'var')
    load([OUT_PATH, 'SMOS_', DIRECTION(1:3),'_v1.mat']);
end


id = unique(data(1:dataInd,1)); %id = id(~isnan(id));
nPoints = length(id);
disp([num2str(nPoints), ' unique grid points within the specified limits!']);

% file output
for i=1:nPoints
    point_id = id(i);
    point_f = find(data(:,1) == id(i));
    point_lat = data(point_f(1), 2);
    point_lon = data(point_f(1), 3);
    
    fid = fopen([OUT_PATH, 'SMOS_',  DIRECTION(1:3), '_', num2str(id(i), '%d'), '.dat'], 'w'); 
    
    fprintf(fid, [num2str(id(i), '%d'), ' ', num2str(point_lat, '%.4f'), ' ', ...
        num2str(point_lon, '%.4f'), '\n']);
    fprintf(fid, 'TIME WS sigmaWS SST sigmaSST\n');
    fprintf(fid, '%.5f ', data(point_f, 4)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', data(point_f, 5)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', data(point_f, 6)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', data(point_f, 7)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', data(point_f, 8)'); fprintf(fid, '\n');
    
    fclose(fid);
    
    plot(point_lon, point_lat, '.'); hold on;
end

