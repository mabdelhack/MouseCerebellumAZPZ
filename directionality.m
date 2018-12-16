function [angles_local, angles_global_vectors, angles_global_points] = directionality(filelocation)
% filelocation = 'C:\Users\Tablaptomon\Documents\Hermina project\DATA2016\PZ\young1_PZ\young1_PZ.mtr';
trees{1} = load_tree(filelocation);
angles_local = cell(1,length(trees{1}));
angles_global_points = cell(1,length(trees{1}));
angles_global_vectors = cell(1,length(trees{1}));
means_global = zeros(1,length(trees{1}));
means_global_vecs = zeros(1,length(trees{1}));
means_cur = zeros(1,length(trees{1}));
glo_ref = [0 1 0];
ref_dir = [1 0 0];
for i = 1:length(trees{1})
    tree_origin(1) = trees{1}{i}.X(1);
    tree_origin(2) = trees{1}{i}.Y(1);
    tree_origin(3) = trees{1}{i}.Z(1);
    trees{1}{i} = resample_tree(trees{1}{i},4);
    angles_local{i} = zeros(length(trees{1}{i}.X),1);
    angles_global_points{i} = zeros(length(trees{1}{i}.X),1);
    for j = 1:length(trees{1}{i}.X)
        if j == 1
            angles_local{i}(j) = 0;
            angles_global_points{i}(j,1) = 0;
            angles_global_points{i}(j,2) = 0;
        elseif j ==2
            angles_local{i}(j) = 0;
            
            glo_vector(1) = trees{1}{i}.X(j) - tree_origin(1);
            glo_vector(2) = trees{1}{i}.Y(j) - tree_origin(2);
            glo_vector(3) = trees{1}{i}.Z(j) - tree_origin(3);
            glo_angle = dot(glo_vector,glo_ref)/(norm(glo_vector));
            glo_angle = sign(dot(glo_vector,ref_dir))*real(acos(glo_angle));
            glo_angle = glo_angle*180/pi;
            angles_global_points{i}(j,1) = glo_angle;
            angles_global_points{i}(j,2) = trees{1}{i}.Y(j);
            prev_j = find(trees{1}{i}.dA(j,:) == 1);
            cur_vector(1) = trees{1}{i}.X(j) - trees{1}{i}.X(prev_j);
            cur_vector(2) = trees{1}{i}.Y(j) - trees{1}{i}.Y(prev_j);
            cur_vector(3) = trees{1}{i}.Z(j) - trees{1}{i}.Z(prev_j);
            vec_angle = dot(cur_vector,glo_ref)/(norm(cur_vector));
            vec_angle = sign(dot(cur_vector,ref_dir))*real(acos(vec_angle));
            vec_angle = vec_angle*180/pi;
            angles_global_vectors{i}(j,1) = vec_angle;
            angles_global_vectors{i}(j,2) = trees{1}{i}.Y(prev_j);
        else
            prev_j = find(trees{1}{i}.dA(j,:) == 1);
            cur_vector(1) = trees{1}{i}.X(j) - trees{1}{i}.X(prev_j);
            cur_vector(2) = trees{1}{i}.Y(j) - trees{1}{i}.Y(prev_j);
            cur_vector(3) = trees{1}{i}.Z(j) - trees{1}{i}.Z(prev_j);
            if prev_j ~=1
                ref_vector(1) = trees{1}{i}.X(prev_j) - trees{1}{i}.X(trees{1}{i}.dA(prev_j,:) == 1);
                ref_vector(2) = trees{1}{i}.Y(prev_j) - trees{1}{i}.Y(trees{1}{i}.dA(prev_j,:) == 1);
                ref_vector(3) = trees{1}{i}.Z(prev_j) - trees{1}{i}.Z(trees{1}{i}.dA(prev_j,:) == 1);
            else
                ref_vector(1) = trees{1}{i}.X(2) - trees{1}{i}.X(prev_j);
                ref_vector(2) = trees{1}{i}.Y(2) - trees{1}{i}.Y(prev_j);
                ref_vector(3) = trees{1}{i}.Z(2) - trees{1}{i}.Z(prev_j);
            end
            cur_angle = dot(cur_vector,ref_vector)/(norm(cur_vector)*norm(ref_vector));
            cur_angle = real(acos(cur_angle));
            cur_angle = cur_angle*180/pi;
            angles_local{i}(j) = cur_angle;
            glo_vector(1) = trees{1}{i}.X(j) - tree_origin(1);
            glo_vector(2) = trees{1}{i}.Y(j) - tree_origin(2);
            glo_vector(3) = trees{1}{i}.Z(j) - tree_origin(3);
            glo_angle = dot(glo_vector,glo_ref)/(norm(glo_vector));
            glo_angle = sign(dot(glo_vector,ref_dir))*real(acos(glo_angle));
            glo_angle = glo_angle*180/pi;
            angles_global_points{i}(j,1) = glo_angle;
            angles_global_points{i}(j,2) = trees{1}{i}.Y(j);
            
            vec_angle = dot(cur_vector,glo_ref)/(norm(cur_vector));
            vec_angle = sign(dot(cur_vector,ref_dir))*real(acos(vec_angle));
            vec_angle = vec_angle*180/pi;
            angles_global_vectors{i}(j,1) = vec_angle;
            angles_global_vectors{i}(j,2) = trees{1}{i}.Y(prev_j);
            
        end
        
    end
    means_cur(i) = mean(angles_local{i});
    means_global(i) = mean(angles_global_points{i}(:,2));
    means_global_vecs(i) = mean(angles_global_vectors{i}(:,2));
%     figure;
%     hist(angles_local{i});
%     xlim([0 180]);
end
% figure;
% plot(means_cur);
% ylim([0 180]);
% figure;
% plot(means_global);
% ylim([0 180]);
% figure;
% plot(means_global_vecs);
% ylim([0 180]);