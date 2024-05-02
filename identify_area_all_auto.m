%% This script requires two data files:
%% cood_ac_cassius.mat and BB_recordingInfoTable_recordInfo.csv

monkeyName = input('Enter the name of the monkey (Cassius or Miyagi): ','s');

% Load coordinate file for AC.
load(sprintf('coord_ac_%s.mat',monkeyName))

% Load recording info file.
%recordInfo = readtable('BB_recordingInfoTable_recordInfo.csv');
recordInfo = importfile('BB_recordingInfoTable_recordInfo.csv');

% Find indices of all DMR sessions with AC chamber.
if strcmp(monkeyName,'Cassius')
	idx_dmr = find(recordInfo.monkeyID=='MrC' & recordInfo.chamber=='AC' & recordInfo.stimulus=='ripplesF');
elseif strcmp(monkeyName,'Miyagi')
	idx_dmr = find(recordInfo.monkeyID=='MrM' & recordInfo.chamber=='AC' & recordInfo.stimulus=='ripplesF');
else
	fprintf('\n\n!!! Error: Cannot find the recording info needed. !!!\n\n')
	return
end

% Find areas of all recordings and mark them.
for k = 1:length(idx_dmr)
	for j = 1:size(coord_ac,2)
		for i = 1:size(coord_ac,1)
			if isequal(coord_ac{i,j},[recordInfo.guideTubeX(idx_dmr(k)),recordInfo.guideTubeY(idx_dmr(k))])
				recordInfo.area{idx_dmr(k)} = coord_ac{1,j};
			end
		end
	end
end

idx_a1 = find(strcmp(recordInfo.area,'A1'));
idx_rost = find(strcmp(recordInfo.area,'R'));
idx_beltL = find(strcmp(recordInfo.area,'BeltL'));
idx_beltM = find(strcmp(recordInfo.area,'BeltM'));


% Make a list of sorted directories for each recording area.

% For A1
for k = 1:length(idx_a1)
	driveDir = fullfile('~','kiloSorted_DMR',sprintf('Mr%s-%i',monkeyName,recordInfo.recordDate(idx_a1(k))),sprintf('D%i_AC_R%i',recordInfo.driveID(idx_a1(k)),recordInfo.recordGroup(idx_a1(k))));
	spikeDir = fullfile(driveDir,'KS2_7_AC');
	clustInfoDir = 'ClusterInfo';
	fout_recordInfo = fullfile(spikeDir,clustInfoDir,'record_info.txt');

	if isfile(fout_recordInfo)
		delete(fout_recordInfo)
	end

	try
		fid = fopen(fout_recordInfo,'a');
		fprintf(fid,'Monkey: %s\n',monkeyName);
		fprintf(fid,'Chamber: AC\n');
		fprintf(fid,'Area: A1');
		fclose(fid);
	catch
		fprintf('\n!Error: Cannot find the sorted directory for %s. Skipping...\n\n',spikeDir)
	end
end

% For R
for k = 1:length(idx_rost)
	driveDir = fullfile('~','kiloSorted_DMR',sprintf('Mr%s-%i',monkeyName,recordInfo.recordDate(idx_rost(k))),sprintf('D%i_AC_R%i',recordInfo.driveID(idx_rost(k)),recordInfo.recordGroup(idx_rost(k))));
	spikeDir = fullfile(driveDir,'KS2_7_AC');
	clustInfoDir = 'ClusterInfo';
	fout_recordInfo = fullfile(spikeDir,clustInfoDir,'record_info.txt');

	if isfile(fout_recordInfo)
		delete(fout_recordInfo)
	end

	try
		fid = fopen(fout_recordInfo,'a');
		fprintf(fid,'Monkey: %s\n',monkeyName);
		fprintf(fid,'Chamber: AC\n');
		fprintf(fid,'Area: R');
		fclose(fid);
	catch
		fprintf('\n!Error: Cannot find the sorted directory for %s. Skipping...\n\n',spikeDir)
	end
end

% For lateral Belt
for k = 1:length(idx_beltL)
	driveDir = fullfile('~','kiloSorted_DMR',sprintf('Mr%s-%i',monkeyName,recordInfo.recordDate(idx_beltL(k))),sprintf('D%i_AC_R%i',recordInfo.driveID(idx_beltL(k)),recordInfo.recordGroup(idx_beltL(k))));
	spikeDir = fullfile(driveDir,'KS2_7_AC');
	clustInfoDir = 'ClusterInfo';
	fout_recordInfo = fullfile(spikeDir,clustInfoDir,'record_info.txt');

	if isfile(fout_recordInfo)
		delete(fout_recordInfo)
	end

	try
		fid = fopen(fout_recordInfo,'a');
		fprintf(fid,'Monkey: %s\n',monkeyName);
		fprintf(fid,'Chamber: AC\n');
		fprintf(fid,'Area: lateral Belt');
		fclose(fid);
	catch
		fprintf('\n!Error: Cannot find the sorted directory for %s. Skipping...\n\n',spikeDir)
	end
end

% For medial Belt
for k = 1:length(idx_beltM)
	driveDir = fullfile('~','kiloSorted_DMR',sprintf('Mr%s-%i',monkeyName,recordInfo.recordDate(idx_beltM(k))),sprintf('D%i_AC_R%i',recordInfo.driveID(idx_beltM(k)),recordInfo.recordGroup(idx_beltM(k))));
	spikeDir = fullfile(driveDir,'KS2_7_AC');
	clustInfoDir = 'ClusterInfo';
	fout_recordInfo = fullfile(spikeDir,clustInfoDir,'record_info.txt');

	if isfile(fout_recordInfo)
		delete(fout_recordInfo)
	end

	try
		fid = fopen(fout_recordInfo,'a');
		fprintf(fid,'Monkey: %s\n',monkeyName);
		fprintf(fid,'Chamber: AC\n');
		fprintf(fid,'Area: medial Belt');
		fclose(fid);
	catch
		fprintf('\n!Error: Cannot find the sorted directory for %s. Skipping...\n\n',spikeDir)
	end
end





function recordInfo = importfile(filename, dataLines)
% Auto-generated by MATLAB on 23-May-2020 00:13:18

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options
opts = delimitedTextImportOptions("NumVariables", 20);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["blockName", "tankName", "monkeyID", "experiment", "recordDate", "recordTime", "stimulus", "recordingLog", "freqSeq", "taskVar", "recordGroup", "chamber", "driveID", "electrodeType", "guideTubeX", "guideTubeY", "guideTubeZ", "nChannel", "recordDepth", "dataIndx"];
opts.VariableTypes = ["categorical", "double", "categorical", "double", "double", "double", "categorical", "double", "categorical", "categorical", "double", "categorical", "double", "categorical", "double", "double", "double", "double", "double", "double"];
opts = setvaropts(opts, [2, 4, 8], "TrimNonNumeric", true);
opts = setvaropts(opts, [2, 4, 8], "ThousandsSeparator", ",");
opts = setvaropts(opts, [1, 3, 7, 9, 10, 12, 14], "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
recordInfo = readtable(filename, opts);

end