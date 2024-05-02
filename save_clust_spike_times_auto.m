% Setup directories
keyword = input('Enter keyword to filter target sessions: ','s');

% Exceptions
exceptions = {};
tag_exception = 1;
while tag_exception == 1
	exception = input('Any exceptions?("no" for no more): ','s');
	if strcmp(exception,'no')
		tag_exception = 0;
	else
		exceptions{end+1} = exception;
	end
end

%ksDMRDir = fullfile('i:','Parooa','Synapse','i','kiloSorted_DMR');
ksDMRDir = fullfile('~','kiloSorted_DMR');
sortedDir = dir(fullfile(ksDMRDir,sprintf('*%s*',keyword),'*AC*','KS2_*_AC'));

%return

% log file
dir_log = fullfile('~','Casmiya');
%dir_log = fullfile('f:','Poincare','Research','Auditory','Toolbox','CohenLab','CohenSpikeSortingMetrics-master');

% Some parameters
data_type = 'kilo';
fs = 24414.0625;

dname_new = 'ClusterInfo';
fname_log = 'log_changes_to_KS.txt';

% Make changes to target directories.
for idx_dir = 1:length(sortedDir)
	dirToken = split(sortedDir(idx_dir).folder,'_DMR');
	if ~contains(sortedDir(idx_dir).folder,exceptions)
		fprintf('\nProcessing %s%s%s ...\n',dirToken{2},filesep,sortedDir(idx_dir).name)
		tic
		%dir_data = fullfile(sortedDir(idx_dir).folder,sortedDir(idx_dir).name);
		%dir_new = fullfile(sortedDir(idx_dir).folder,sortedDir(idx_dir).name,dname_new);
		%if exist(dir_new,'dir')
		%	%display('*** Output directory already exists. Replacing results...')
		%	display('*** Output directory already exists. Backing up...')
		%	%movefile(dir_new,[dir_new '_' datestr(now,'yyyy-mm-dd_HH-MM-ss')])
		%	movefile(dir_new,[dir_new '_' datestr(now,'yyyymmdd_HHMMss')])
		%end
		%display('*** Creating output directory...')
		%mkdir(dir_new)
		try
			%movefile(fullfile(dir_data,'cluster_group_*.tsv'),dname_new);
			%movefile(fullfile(dir_data,'cluster_info_*.tsv'),dname_new);
			save_all_clust_spike_times_pwd(fullfile(sortedDir(idx_dir).folder,'KS2_7_AC'))
			save_good_clust_spike_times_pwd(fullfile(sortedDir(idx_dir).folder,'KS2_7_AC'))
		catch
			fprintf('*** Error: Could not process %s%s%s. Skipped ...\n\n',dirToken{2},filesep,sortedDir(idx_dir).name)
			fid = fopen(fullfile(dir_log,fname_log),'a');
			fprintf(fid,'\n\n---------- %s ----------\n', datestr(now,'yyyymmdd_HHMMss'));
			fprintf(fid,'*** Error: Could not process %s%s%s.\n\n',dirToken{2},filesep,sortedDir(idx_dir).name);
			fclose(fid);
			continue
		end
		toc
		fprintf('\n')
	%else
	%	fprintf('\nSkipping %s%s%s ...\n\n',dirToken{2},filesep,sortedDir(idx_dir).name)
	end
end
fprintf('\nSaving cluster spike times completed!\n\n')


