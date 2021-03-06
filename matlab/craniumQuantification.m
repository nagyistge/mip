function [distResults, patients] = craniumQuantification ...
    (suffix, data_path, slice_num, option)
% CRANIUMQUANTIFICATION Provides an  cranial atrophy calculation.
%
%   Problemler var. Iki kere calisma var bi fonk.
%   Cortical neden 800 ki? 25?
%   
% SYNOPSIS:
%     craniumQuantification('gz','registered/0.5mm', 'reg', 'noverbose')
%     craniumQuantification('png','yue', 'yue', 'noverbose')
%
% DESCRIPTION:
%    This function helps to calculate cranial atrophy of that brain.
%    To do this, function needs specific slice of a preprocessed* brain, and
%    the cranium image.
%    Moreover, function supports regular expression while sending
%    file name.
%    Function accepts one (at least one which interest in file name),
%    or two parameters.
%    Default path is result of !pwd.
%
%    [*] preprocessed: This function needs output of the FAST (FMRIB tool)
%
%  brainSkull is the image which has the cranium.
%  Author(s): Osman Baskaya <osman.baskaya@computer.org>
%  $Date: 2012/02/20

%% Definition of some constants and setting some options

DATASET_PATH = '/home/tyr/Documents/datasets/mipdatasets/';
BRAIN_PATH = 'brains/';
SKULL_PATH = 'skulls/';

format long

%% Get the Data
%close all
%clc
% if nargin == 1
%     path = cd;
% elseif nargin > 2
%     fprintf('wrong number of arg');
%     return
% end

brain_full_path = strcat(DATASET_PATH, BRAIN_PATH, data_path);
skull_full_path = strcat(DATASET_PATH, SKULL_PATH, data_path);
if (strcmp(option, 'verbose'))
    fprintf('\n\n%s\n\n','******Atrophy Quantification******');
end

image_files = getData(suffix, brain_full_path);

%% Skull Adding

D = [];
patients = java.util.HashMap;
number_of_data = length(image_files);
expert_scores = zeros(number_of_data, 1);

for k=1:number_of_data
    
    % Get the name of the data in image_files by one by.
    dataName = image_files(k).name;
    current_patient_score = get_patient_exp_score(dataName);
    patients.put(dataName, current_patient_score);
    expert_scores(k) = current_patient_score;
    
    fprintf('%i) Data is %s\n', k, dataName);
    
    % Read Betsurf output and related slice.
    skull = read_mri(dataName, skull_full_path);
    skull = skull(:,:, slice_num);
    

        
    % Read Fast output and related slice.
    FAST_brain = read_mri(dataName, brain_full_path);
    FAST_brain = FAST_brain(:,:, slice_num);
    hemisDist = eval_IHA(FAST_brain, skull, dataName, 800, option);
    cortDist = eval_HCA(FAST_brain, skull, dataName, 25, option);
    D = [D; [hemisDist, cortDist]]; 
end

distResults = [(1:number_of_data)', D, D(:,1)+D(:,2), expert_scores];
end

