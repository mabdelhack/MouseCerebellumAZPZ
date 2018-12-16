close all;
clear;
treespath = fullfile(pwd, 'TREES1.15');
run(fullfile(treespath, 'start_trees.m'));
%%Setting the main directory and creating the empty array
addpath(fullfile(pwd, 'polygons2d'));
location = fullfile('.','data');
morphloc = {'AZ','PZ'};
ages = {'young*','adult*'};
resampling_factor = 1;
means = zeros(2,2);
stds = zeros(2,2);
% files = dir(neuron_directory);
% % Get a logical vector that tells which is a directory.
% dirFlags = [files.isdir];
% Folders = files(dirFlags);
% Folders(1:2) = []; %removing the . and ..
Trees = cell(2,2); %This is the main variables
%%Get the subfolders and loading trees to group them
bins = 0.05:0.1:1.05;
overlapcount = cell(2,2);
allhull = []; age = []; reg = []; dc = [];
for i = 1: length(morphloc)
    for j = 1:length(ages)
        foldernames = dir(fullfile(location,morphloc{i},ages{j}));
        overlapcount{i,j} = zeros(1,length(bins)-1);
%         figure('units','normalized','outerposition',[0 0 1 1]);
        for k = 1:length(foldernames)

            %List the swc files
            mtr_files = dir([fullfile(location,morphloc{i},foldernames(k).name), '\*.mtr']);
            mtr_files = extractfield(mtr_files,'name');
            %Making an empty cell array for each tree (preallocation for speed)


            %Loading the tree
            fullfilename = fullfile(location,morphloc{i},foldernames(k).name,mtr_files);
            Trees{i,j}{k} = load_tree(fullfilename{:});

            maxX = [];
            minX = [];
            maxY = [];
            minY = [];

            for l = 1:length(Trees{i,j}{k})
                maxX = [maxX ; max(Trees{i,j}{k}{l}.X)];
                maxY = [maxY ; max(Trees{i,j}{k}{l}.Y)];
                minX = [minX ; min(Trees{i,j}{k}{l}.X)];
                minY = [minY ; min(Trees{i,j}{k}{l}.Y)];
            end
            maxX = max(maxX); maxY = max(maxY);
            minX = min(minX); minY = min(minY);
            X = minX:maxX; sizex = length(X);
            Y = minY:maxY; sizey = length(Y);
            X = repmat(X,sizey,1);
            X = reshape(X,1,sizex*sizey);
            Y = repmat(Y,1,sizex);
            densitymap = zeros(1,length(X));
            chull_hull = zeros(1,length(Trees{i,j}{k}));

            for l = 1:length(Trees{i,j}{k})
                Trees{i,j}{k}{l} = resample_tree(Trees{i,j}{k}{l},resampling_factor);
                [hull, ~] = hull_tree(Trees{i,j}{k}{l},2,[],[],[],'-2d');
                [~, chull] = chull_tree(Trees{i,j}{k}{l},[],[],[],0.5,'-2d');
                chull = chull.XY(chull.ch,:);
                chull = expandPolygon(chull, 2);
                chull = chull{:};
                inflog = isinf(chull);
                [infx,~] = find(inflog);
                chull(infx,:) = [];
%                 figure; hold on; set(gcf, 'Color', 'w'); 
%                 axis equal;
%                 axis off;
%                 patch(chull(:,1),chull(:,2),[0 1 0],'EdgeColor','none');
        %         close all;
                inc = in_c (X, Y, hull); patchplotter (hull, [0 1 0]);
%                 plot_tree(tran_tree(Trees{i,j}{k}{l}, [0,0,100]));
%                 fpat='C:\Users\Tablaptomon\Documents\Hermina project\figures\spacefilling_hullchull';
%                 fnam=sprintf([morphloc{i},'_',ages{j}(1:end-1),'_',num2str((k-1)*10+l,'%02.0f'),'.fig']);
                
%                 saveas(gcf,[fpat,filesep,fnam],'fig'); 
                inch = inpolygon(X, Y, chull(:,1),chull(:,2)); %cplotter (chull, [1 0 0]);
%                 figure;
%                 hold on;
%                 plot (X(~inc), Y(~inc), 'r.');
%                 plot (X(inch), Y(inch), 'g.');
%                 plot (X(inc), Y(inc), 'k.'); 
                chull_hull(l) = sum(inc)/sum(inch);

            end
            close all;
            allhull = [allhull ; chull_hull'];
            age = [age;repmat(j,length(chull_hull),1)];
            reg = [reg;repmat(i,length(chull_hull),1)];
            ratiomean(i,j,k) = mean(chull_hull);
            ratiostd(i,j,k) = std(chull_hull);   
        end

        
    end

end
ratiomean = mean(ratiomean,3);
ratiostd = mean(ratiostd,3);
figure; hold on;
hb = bar(ratiomean');
pause(0.1); %pause allows the figure to be created
for ib = 1:numel(hb)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = hb(ib).XData+hb(ib).XOffset;
    errorbar(xData,ratiomean(ib,:),ratiostd(ib,:)/sqrt(30),'k.')
end
legend(morphloc)
title('Mean hull/convex hull');
set(gca,'XTick',1:2,'XTickLabel',{'Young', 'Old'});



