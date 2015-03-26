% testing to see if grid points with the same id always correspond to the
% same place in the map (long, lat), namely if the id is an actual id of a
% point in space. => Turns out, it is!

clear;clc;

path = 'C:\Users\Constantinos\Desktop\smos\';
D = dir(path);
FLAG = true;
marker = {'x', 'o', '.', '+', '*', 's', 'd', '^', 'v', '<', '>', 'p', 'h'};

for i=1:length(D)
    if ~isempty(strfind(D(i).name, '.DBL')) && ...
            isempty(strfind(D(i).name, '.TXT'))
        filename = D(i).name;
        disp(filename);
        data = eqn_readSmosDBL([path, filename]);
        proc = data(data(:,5) > -990, :);
        
        if FLAG
            uid = unique(proc(:,1));
            r = randi(size(uid, 1), 1);
            target_id = uid(r); disp(['Target_ID = ', num2str(target_id)]);
            FLAG = false;
        end
        row = find(proc(:,1) == target_id);
        if isempty(row)
            disp('grid point not found on this file!');
        else
            if length(row) > 1
                disp('More than one records of this grid point were found!');
            else
                plot(proc(row, 3), proc(row, 4), marker{mod(i, 13) + 1}); hold on;
            end
        end
        
        hold off;
    end
end



