treespath = fullfile(pwd, 'TREES1.15');
regions = {'AZ', 'PZ'};
run(fullfile(treespath, 'start_trees.m'));
%%Setting the main directory and creating the empty array
neuron_directory = fullfile('.', 'data');
scaling_factor = 2;

for region = 1:length(regions)
    
    region_directory = fullfile(neuron_directory, regions{region});
    files = dir(region_directory);
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    Folders = files(dirFlags);
    Folders(1:2) = []; %removing the . and ..
    Trees = cell(size(Folders,1),1); %This is the main variables
    %%Get the subfolders and loading trees to group them
    for i = 1:size(Folders,1);
        %Each subfolder name
        sub_folder = [region_directory,filesep, Folders(i).name, filesep];
        %List the swc files
        swc_files = dir([sub_folder, '*.swc']);
        swc_files = extractfield(swc_files,'name');
        %Making an empty cell array for each tree (preallocation for speed)
        Trees{i} = cell(size(swc_files,2),1);
        figure; hold on;
        X = []; Y=[]; Z=[];
        %Finding the translation distances

        for j = 1:size(swc_files,2)
            %Loading the tree and repairing
            Trees{i}{j} = load_tree([sub_folder, swc_files{j}]);
            Trees{i}{j} = repair_tree(Trees{i}{j});

        end
        T = [Trees{i}{1}.X(1), Trees{i}{1}.Y(1), Trees{i}{1}.Z(1)];
        for j = 1:size(swc_files,2)
            Trees{i}{j} = tran_tree(Trees{i}{j}, -T);
            %Loading soma information for rotating the tree
            X = [X ; mean(Trees{i}{j}.X(Trees{i}{j}.R==1))];
            Y = [Y ; mean(Trees{i}{j}.Y(Trees{i}{j}.R==1))];
            Z = [Z ; mean(Trees{i}{j}.Z(Trees{i}{j}.R==1))];
            plot_tree(Trees{i}{j},rand(1,3)); 

            %Removing soma from the tree
            Trees{i}{j} = delete_tree(Trees{i}{j},find(Trees{i}{j}.R == 1));
        end

        %Finding the orientation of the tree to get the rotation angle
        V = pca([X,Y]);
        Rot_anglez = atan(V(2,1)/V(1,1));
        Rot_anglez = Rot_anglez/pi*180;
        V = pca([Y,Z]);
        Rot_anglex = acos(det(V)*V(1,1));
        Rot_anglex = Rot_anglex/pi*180;
        V = pca([X,Z]);
        Rot_angley = acos(det(V)*V(1,1));
        Rot_angley = Rot_angley/pi*180;
        %Rotate, translate, scale and then plot
        figure;
        flip = 0;


        for j = 1:size(swc_files,2)

            Trees{i}{j} = rot_tree(Trees{i}{j}, [0,0,Rot_anglez]);

            Trees{i}{j} = scale_tree(Trees{i}{j}, [1,1,scaling_factor]);
            if flip == 1
                Trees{i}{j}.Y = -Trees{i}{j}.Y;
            end
            Trees{i}{j}.D(:) = 1;
        end
        if Trees{i}{1}.Y(end) < Trees{i}{1}.Y(1)
            flip = 1;
        end

        for j = 1:size(swc_files,2)

            if flip == 1
                Trees{i}{j}.Y = -Trees{i}{j}.Y;
            end
            plot_tree(Trees{i}{j},rand(1,3)); 

        end

        drawnow;
        %Now save each forest into an mtr file
        save_tree(Trees{i},[sub_folder,Folders(i).name,'.mtr']);
    end
end