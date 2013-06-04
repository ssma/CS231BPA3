% Example of how to use the BuildPyramid function
% set image_dir and data_dir to your actual directories
addpath('liblinear-1.93/matlab');
im_dir = '../scene_categories';
image_dir = [{'../scene_categories/PARoffice'},{'../scene_categories/MITmountain'}, {'../scene_categories/MIThighway'}, ...
        {'../scene_categories/MITforest'}, {'../scene_categories/livingroom'}, {'../scene_categories/industrial'},...
        {'../scene_categories/kitchen'}, {'../scene_categories/MITtallbuilding'}, {'../scene_categories/store'}...
        {'../scene_categories/MITopencountry'}, {'../scene_categories/MITstreet'}, {'../scene_categories/MITinsidecity'}, ...
        {'../scene_categories/MITcoast'}, {'../scene_categories/CALsuburb'}, {'../scene_categories/bedroom'}]; 
    
data_dir = 'new_data2';

% for other parameters, see BuildPyramid
%fnames = []; %struct(length(image_dir),1);
filenames=[];
labels= [];
for i = 1:length(image_dir)
   % fnames =[fnames; dir(fullfile(image_dir{i}, '*.jpg'))];
    fnames = dir(fullfile(image_dir{i}, '*.jpg'));
    num_files = size(fnames,1);
    im_names =  cell(num_files,1);
    im_labels = zeros(num_files,1);
    for f = 1:num_files
	im_names{f} = strcat(image_dir{i},'/',fnames(f).name);
    im_labels(f) = i;
    end
    %filenames = cell(num_files,1);
    labels = [labels; im_labels];
    filenames = [filenames; im_names];
end



%fnames = dir(fullfile(image_dir, '*.jpg'));
%num_files = size(fnames,1);
%filenames = cell(num_files,1);

% for f = 1:num_files
% 	filenames{f} = fnames(f).name;
% end

% return pyramid descriptors for all files in filenames
pyramid_all = BuildPyramid(filenames,im_dir,data_dir);
%%
training_data=[];
training_label = [];
testing_data = []; %pyramid_all;
testing_label = [];%labels;
test_i =[];
train_i= [];
for i = 1:length(image_dir)
    I = find(labels ==i);
    if length(I)>100
        k = randperm(length(I));
      %  training_data = [training_data; pyramid_all(I(k(1:100)),:)];
      train_i = [train_i; I(k(1:100))];
        temp(1:100)= i;
        training_label = [training_label; temp'];
       % testing_data(I(k(1:100)),:) =[];
     %  testing_data = [testing_data; pyramid_all(I(k(101:end)),:)];
       testing_label = [testing_label; labels(I(k(101:end)))];
       test_i = [test_i; I(k(101:end))];
        %testing_label(I(k(1:100))) = [];
        
    end
end

training_data = pyramid_all(train_i,:);
testing_data = pyramid_all(test_i,:);

%K1 = hist_isect(training_data, training_data);
%model = train(training_label, sparse(K1));% [,'liblinear_options', 'col']);
%K2 = hist_isect(testing_data, training_data);
%[predicted_label, accuracy, decision_values] = predict(testing_label, sparse(K2), model );

%%%% LINEAR TRAINING WITHOUT KERNEL %%%%%%%%%%%%%

model = train(training_label, sparse(training_data), '-v 5');% [,'liblinear_options', 'col']);
[predicted_label, accuracy, decision_values] = predict(testing_label, sparse(testing_data), model );
% build a pyramid with a different dictionary size without re-generating the
% sift descriptors.
%pyramid_all2 = BuildPyramid(filenames,image_dir,data_dir,1000,100,50,4,1);

% compute histogram intersection kernel
%K = hist_isect(pyramid_all, pyramid_all); 
%model = train(training_label_vector, training_instance_matrix [,'liblinear_options', 'col']);


%%model = train(training_label_vector, training_instance_matrix [,'liblinear_options', 'col']);

% for faster performance, compile and use hist_isect_c:
% K = hist_isect_c(pyramid_all, pyramid_all);
