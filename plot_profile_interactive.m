%clear; close all

monkeyID = input('Which monkey? [(C)assius/(M)iyagi] ','s');
%monkeyID = 'C';
if monkeyID == 'C'
	monkeyName = 'Cassius';
elseif monkeyID == 'M'
	monkeyName = 'Miyagi';
else
	fprintf('\n!!!Wrong monkey ID entered!!! Exiting.\n\n')
	return
end

% Import recording information
recordInfo = importfile(fullfile('~','Casmiya','BB_recordingInfoTable_recordInfo.csv'));
dir_resultData = fullfile('~','audiDeci','mat','audiRespCSD');
dir_resultFig = fullfile('~','audiDeci','results','audiRespCSD');

if monkeyID == 'C'
	target = dir(fullfile(dir_resultFig,'MrC*'));
elseif monkeyID == 'M'
	target = dir(fullfile(dir_resultFig,'MrM*'));
end

if isempty(target)
	fprintf("\nError: Failed to access recording data! Please check if the network drive is properly mounted.\n\n")
	return
end

runPlot = 'n';

fh_MUA = figure;
fh_CSD1 = figure;
fh_CSD2 = figure;
currPos = get(fh_MUA,'Position'); set(fh_MUA,'Position',[currPos(1),currPos(2),800,800]);
currPos = get(fh_CSD1,'Position'); set(fh_CSD1,'Position',[currPos(1),currPos(2),800,800]);
currPos = get(fh_CSD2,'Position'); set(fh_CSD2,'Position',[currPos(1),currPos(2),800,800]);

idx_dupCoord = [];
%idx_prof = 1;
temp_target = 2;
idx_prof = temp_target;

%for idx_target = 1:size(target,1)
for idx_target = temp_target
	%try
		nameTok = split(target(idx_target).name,'_');
		lamProf(idx_prof) = find_CSD(monkeyID,nameTok{2},recordInfo);

		fprintf('\n\nProcessing %s ...\n',lamProf(idx_prof).dataName);
		
		%%Go through previous targets and check if depth is duplicate (skipped for now)
		%for k = 1:length(lamProf)
		%	lamProf(idx_target).coord;
		%	lamProf(k).coord;
		%	if isequal(lamProf(idx_target).coord,lamProf(k).coord) && k~=idx_target && k~=1
		%		idx_dupCoord(end+1) = idx_target;
		%		f_old = openfig(fullfile(dir_resultFig,sprintf('Mr%s_%i',monkeyID,lamProf(idx_target).date),lamProf(idx_target).figName));
		%		f_new = openfig(fullfile(dir_resultFig,sprintf('Mr%s_%i',monkeyID,lamProf(k).date),lamProf(k).figName));
		%		currPos = get(f_old,'Position'); set(f_old,'Position',[currPos(1),currPos(2),1000,400]);
		%		currPos = get(f_new,'Position'); set(f_new,'Position',[currPos(1),currPos(2),1000,400]);
		%		ans_replaceProf = input('Replace profile? (y/n)','s');
		%		ans_replaceProf = 'y';
		%		if ans_replaceProf == 'n'
		%			runPlot = 'n';
		%		end
		%	end
		%	if runPlot == 'y'
		%		%plot_MUAProfile(lamProf(idx_prof).dataName,lamProf(idx_prof).depth,lamProf(idx_prof).coordPos,fh_MUA,idx_prof)
		%		%plot_CSDProfile(lamProf(idx_prof).dataName,lamProf(idx_prof).depth,lamProf(idx_prof).coordPos,fh_CSD1,fh_CSD2)
		%		idx_prof = idx_prof+1;
		%		plot_MUAProfile(lamProf(idx_prof).date,lamProf(idx_prof).dataName,lamProf(idx_prof).depthPicked,lamProf(idx_prof).timePicked,lamProf(idx_prof).coordPos,fh_MUA,idx_prof)
		%		plot_CSDProfile(lamProf(idx_prof).date,lamProf(idx_prof).dataName,lamProf(idx_prof).depthPicked,lamProf(idx_prof).timePicked,lamProf(idx_prof).coordPos,fh_CSD1,fh_CSD2,idx_prof)
		%	end
		%end

		openfig(fullfile(dir_resultFig,sprintf('Mr%s_%i',monkeyID,lamProf(idx_prof).date),lamProf(idx_prof).figName))
		h_AMC = findobj(gcf, 'type', 'axes');
		%currPos = get(gcf,'Position'); set(gcf,'Position',[currPos(1),currPos(2),1000,400]);
		figBasename = split(lamProf(idx_prof).figName,'.');
		figNameTok = split(figBasename{1},'_');
		figOutFileEPS = sprintf('%s_[%s]_%s_%s_%s_%s_AEP_MUA_CSD.eps',figNameTok{4},strrep(num2str(lamProf(idx_prof).coord),' ','_'),figNameTok{5:7},figNameTok{10});
		figOutFilePNG = sprintf('%s_[%s]_%s_%s_%s_%s_AEP_MUA_CSD.png',figNameTok{4},strrep(num2str(lamProf(idx_prof).coord),' ','_'),figNameTok{5:7},figNameTok{10});
		figOutDir = sprintf('AEP_MUA_CSD_%s',monkeyName);
		if ~exist(figOutDir,'dir')
			mkdir(figOutDir)
		end
		%print(gcf,fullfile(figOutDir,figOutFileEPS),'-depsc','-r300')
		%print(gcf,fullfile(figOutDir,figOutFilePNG),'-dpng','-r300')
		for idx_h = 1:3
			set(h_AMC(idx_h), 'XLim', [0 50] );
		end
		figOutFileTrimEPS = sprintf('%s_[%s]_%s_%s_%s_%s_AEP_MUA_CSD_Trim.eps',figNameTok{4},strrep(num2str(lamProf(idx_prof).coord),' ','_'),figNameTok{5:7},figNameTok{10})
		figOutFileTrimPNG = sprintf('%s_[%s]_%s_%s_%s_%s_AEP_MUA_CSD_Trim.png',figNameTok{4},strrep(num2str(lamProf(idx_prof).coord),' ','_'),figNameTok{5:7},figNameTok{10})
		%print(gcf,fullfile(figOutDir,figOutFileTrimEPS),'-depsc','-r300')
		%print(gcf,fullfile(figOutDir,figOutFileTrimPNG),'-dpng','-r300')

		plot_MUAProfile(lamProf(idx_prof).date,lamProf(idx_prof).dataName,lamProf(idx_prof).depthPicked,lamProf(idx_prof).timePicked,lamProf(idx_prof).coordPos,fh_MUA,idx_prof)
		plot_CSDProfile(lamProf(idx_prof).date,lamProf(idx_prof).dataName,lamProf(idx_prof).depthPicked,lamProf(idx_prof).timePicked,lamProf(idx_prof).coordPos,fh_CSD1,fh_CSD2,idx_prof)
		%idx_prof = idx_prof+1;
	%catch
	%	fprintf('\nError found for Mr%s_%i. Pass!\n',monkeyID,str2num(nameTok{2}))
	%end
	%close all
end






function recordInfo = importfile(filename, dataLines)
%IMPORTFILE Import data from a text file
%  BBRECORDINGINFOTABLERECORDINFO = IMPORTFILE(FILENAME) reads data from
%  text file FILENAME for the default selection.  Returns the data as a
%  table.
%
%  BBRECORDINGINFOTABLERECORDINFO = IMPORTFILE(FILE, DATALINES) reads
%  data for the specified row interval(s) of text file FILENAME. Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  BBrecordingInfoTablerecordInfo = importfile("/Users/jaejin/Library/Mobile Documents/com~apple~CloudDocs/Work/Research/Auditory/Casmiya/BB_recordingInfoTable_recordInfo.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 02-Sep-2020 13:08:34

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 20);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["blockName", "tankName", "monkeyID", "experiment", "recordDate", "recordTime", "stimulus", "recordingLog", "freqSeq", "taskVar", "recordGroup", "chamber", "driveID", "electrodeType", "guideTubeX", "guideTubeY", "guideTubeZ", "nChannel", "recordDepth", "dataIndx"];
opts.VariableTypes = ["categorical", "double", "categorical", "double", "double", "double", "categorical", "double", "categorical", "categorical", "double", "categorical", "double", "categorical", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["blockName", "monkeyID", "stimulus", "freqSeq", "taskVar", "chamber", "electrodeType"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["tankName", "experiment", "recordingLog"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["tankName", "experiment", "recordingLog"], "ThousandsSeparator", ",");

% Import the data
recordInfo = readtable(filename, opts);

end
