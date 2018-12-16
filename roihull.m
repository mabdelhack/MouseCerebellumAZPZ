close all;
clear;
treespath = fullfile('.', 'TREES1.15');
run(fullfile(treespath, 'start_trees.m'));
%%Setting the main directory and creating the empty array
location = fullfile('.','data');
morphloc = {'AZ','PZ'};
ages = {'young*','adult*'};
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
all_ovs = []; age = []; reg = [];
for i = 1: length(morphloc)
    for j = 1:length(ages)
        foldernames = dir(fullfile(location,morphloc{i},ages{j}));
        overlapcount{i,j} = zeros(1,length(bins)-1);
        figure('units','normalized','outerposition',[0 0 1 1]);
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
            densitymap{i,j}{k} = zeros(1,length(X));

            for l = 1:length(Trees{i,j}{k})

                [c, ~] = hull_tree(Trees{i,j}{k}{l},2,[],[],[],'-2d');

                inc = in_c (X, Y, c); %cplotter (c, [1 0 0]);
            %     plot (X(inc), Y(inc), 'k.'); plot (X(~inc), Y(~inc), 'r.');
            %     hold on;
                densitymap{i,j}{k} = densitymap{i,j}{k} + inc;
            end
            densitymap{i,j}{k} = reshape(densitymap{i,j}{k},sizey,sizex);
            densitymap{i,j}{k} = densitymap{i,j}{k}/length(Trees{i,j}{k});
            densitymapl = densitymap{i,j}{k}(densitymap{i,j}{k}>0);
            overlap = histcounts(densitymapl,bins);
            overlapcount{i,j} = overlapcount{i,j} + overlap;
            subplot(4,3,[k,k+3]);
            colormap('hot');
            imagesc(densitymap{i,j}{k});
            
            caxis([0 1]);
            set(gca,'YDir','normal');
            axis off;
            subplot(4,3,k+6);
            yprofile = sum(densitymap{i,j}{k})/size(densitymap{i,j}{k},1);
            plot(yprofile);
            xlim([1 size(densitymap{i,j}{k},2)]);
            ylim([0 1]);
            
        end
        subplot(4,3,10:12);
        plot(overlapcount{i,j}/sum(overlapcount{i,j}));
        ylim([0 0.5]);
        ax1 = axes('Position',[0 0 1 1],'Visible','off');
        text(0.5,0.98,[morphloc{i},' ' ages{j}(1:end-1)],'FontSize',16);
        text(0.05,0.33,'x-axis profile','FontSize',12, 'Rotation',90);
        text(0.05,0.13,'Histogram','FontSize',12, 'Rotation',90);
        h_bar = colorbar('Location', 'east');
        caxis([0 1]);
        set(h_bar, 'Position',[0.93 0.55 0.02 0.38]);
        allcomb = repelem(1:10,overlapcount{i,j});
        all_ovs = [all_ovs ; allcomb'];
        age = [age;repmat(j,length(allcomb),1)];
        reg = [reg;repmat(i,length(allcomb),1)];
        
        means(i,j) = mean(allcomb);
        stds(i,j) = std(allcomb)/sqrt(numel(allcomb));
    end
end
figure;
hold on;
hb = bar(1:2,means');
pause(0.1); %pause allows the figure to be created
for ib = 1:numel(hb)
    %XData property is the tick labels/group centers; XOffset is the offset
    %of each distinct group
    xData = hb(ib).XData+hb(ib).XOffset;
    errorbar(xData,means(ib,:),stds(ib,:),'k.')
end
% errorbar(1-0.15:2-0.15,means(1,:),stds(1,:),'.');
% errorbar(1+0.15:2+0.15,means(2,:),stds(2,:),'.');
legend(morphloc)
title('Mean overlap');
set(gca,'XTick',1:2,'XTickLabel',{'Young', 'Old'});

