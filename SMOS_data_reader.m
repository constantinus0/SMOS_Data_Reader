% SMOS_data_reader

apprRecordsPerFile = 100000;
nVars = 8;
% set direction to 'ASCENDING', 'DESCENDING' or 'ALL'
DIRECTION = 'ALL';
% PATH = ['G:\DATA\SMOS\', DIRECTION, '\'];
% PATH = ['G:\DATA\SMOS\ALL\'];
PATH = 'G:\DATA\SMOS\SMOS_NEW\';
OUT_PATH = 'G:\PROCESSED\SMOS\MEDITERRANEAN\';

D = dir([PATH, '*.DBL']);
nFiles = size(D,1);

% initialize buffers to hold data
data = nan(nFiles*apprRecordsPerFile, nVars);
dataInd = 0;

for i=1:nFiles
    filename = [PATH, D(i).name];
    buffer = eqn_readSmosDBLx(filename);            
    
    % find flagged (FLAG_VALUE = -999)
    f = all(buffer(:, 5:end) < -990, 2);
    
    % if the flagged are less than the number of records, then save the
    % non-flagged records to the data matrix
    sb = size(buffer, 1) - sum(f);
    if sb > 0
        % check ascending/descending path
        % first time index
        [minT, minTind] = min(buffer(~f,4));
        % last time index
        [maxT, maxTind] = max(buffer(~f,4));
        if buffer(maxTind, 2) > buffer(minTind, 2)
            satPass = 'ASCENDING';
        elseif buffer(maxTind, 2) < buffer(minTind, 2)
            satPass = 'DESCENDING';
        else
            error('Error 66!');
        end
        
        if strcmp(DIRECTION, satPass) || strcmp(DIRECTION, 'ALL')
            data(dataInd+1:dataInd+sb, :) = buffer(~f, :);
            dataInd = dataInd + sb;
        else
            
        end
    end
end

% clear unused entries in data matrix
data(dataInd+1:end, :) = [];

% convert time to MATLAB format
data(:,4) = data(:,4) + datenum(2000,1,1);

% save the list of filenames as well. This way, if a new dataset emerges
% you can easily check if it has been processed into the 'data' matrix or
% not.
save([OUT_PATH, 'SMOS_', DIRECTION(1:3),'_v1.mat'], 'data', 'D');

%% Grid-point Time Series

if ~exist('data', 'var')
    load([OUT_PATH, 'SMOS_', DIRECTION(1:3),'_v1.mat']);
end

% find unique grid points
id = unique(data(:,1));
nPoints = length(id);
disp([num2str(nPoints), ' unique grid points found!']);

% % Plot Points within the Aegean Sea area
figure(1);
plot(data(:,3), data(:,2), 'x');
set(gca, 'xlim', [23.3999 26.7833], 'ylim', [35.5627 39.5000]);

% select points within specific geographical limits
% lat_lims = 39.12222 + [-0.05,  +0.05];
lat_lims = [30.37, 48.7]; % lat_lims = [35.5627, 39.5000];
flat = find(data(:,2) >= lat_lims(1) & data(:,2) <= lat_lims(2));
% lon_lims = 25.345556 + [-0.05,  +0.05];
lon_lims = [-8.5,  43.17]; % lon_lims = [23.3999,  26.7833];
flon = find(data(:,3) >= lon_lims(1) & data(:,3) <= lon_lims(2));

f = intersect(flat, flon);
sdata = data(f, :);

id = unique(sdata(:,1));
nPoints = length(id);
disp([num2str(nPoints), ' unique grid points within the specified limits!']);

% file output
for i=1:nPoints
    point_id = id(i);
    point_f = find(sdata(:,1) == id(i));
    point_lat = sdata(point_f(1), 2);
    point_lon = sdata(point_f(1), 3);
    
    fid = fopen([OUT_PATH, 'SMOS_',  DIRECTION(1:3), '_', num2str(id(i), '%d'), '.dat'], 'w'); 
    
    fprintf(fid, [num2str(id(i), '%d'), ' ', num2str(point_lat, '%.4f'), ' ', ...
        num2str(point_lon, '%.4f'), '\n']);
    fprintf(fid, 'TIME WS sigmaWS SST sigmaSST\n');
    fprintf(fid, '%.5f ', sdata(point_f, 4)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', sdata(point_f, 5)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', sdata(point_f, 6)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', sdata(point_f, 7)'); fprintf(fid, '\n');
    fprintf(fid, '%f ', sdata(point_f, 8)'); fprintf(fid, '\n');
    
    fclose(fid);
end

% if nPoints == 1
%     % Plotting Sample series
%     xticks = (fix(min(sdata(:,4))):5:ceil(max(sdata(:,4))))';
%     xticklabels = datestr(xticks, 'dd mmm yy');
%     for i=1:1%nPoints
%         f_id = find(sdata(:,1) == id(i));
% 
%     %     plot(sdata(f_id,4), sdata(f_id,11), '-x');
%     %     set(gca, 'xtick', xticks, 'xticklabel', xticklabels);
%         disp(['Target point ID: ', num2str(sdata(f_id(1), 1))]);
%         [datestr(sdata(f_id,4), 'dd mmm yyyy '), num2str(sdata(f_id,11), '%.6f')]
%     end
%     
% end

