%function [spikeTimesPerClust] = save_good_clust_spike_times(sessDate, areaName, dir_a1, dir_belt)
function [spikeTimesPerClust] = save_good_clust_spike_times(sessDate, areaName)

	%sessDate = input('Enter session date (e.g. 190328): ','s');
	%areaName = input('Enter AC area (a1 or belt): ','s');

	load(fullfile('~','kiloSorted_DMR','Info','spike_data_info.mat'));

	if strcmp(areaName,'a1')
		spikeDir = dir_a1{find(contains(dir_a1(:,1),sessDate)),1};
	elseif strcmp(areaName,'belt')
		spikeDir = dir_belt{find(contains(dir_belt(:,1),sessDate)),1};
	else
		display('***Error:Wrong area entered!')
		return
	end
	
	fname_out = 'spike_times_good_clust.mat';
	fname_out_token = 'spike_times_good_clust';
	
	try
		clustInfo = tdfread(fullfile(spikeDir,'cluster_info_new.tsv'));
		spikeClust = readNPY(fullfile(spikeDir,'spike_clusters.npy'));
		spikeTimes = readNPY(fullfile(spikeDir,'spike_times.npy'));
		idx_row = 1;
		for idx_clust = 1:length(clustInfo.group)
			if strcmp(clustInfo.group(idx_clust,:),'good ')
				spikeTimesPerClust{idx_row,1} = clustInfo.id(idx_clust);
				spikeTimesPerClust{idx_row,2} = spikeTimes(find(spikeClust==clustInfo.id(idx_clust)));
				idx_row = idx_row+1;
			end
		end
		fprintf('\nSaving spike times for %s ...\n',spikeDir);
		if exist(fullfile(spikeDir,fname_out))
			movefile(fullfile(spikeDir,fname_out),fullfile(spikeDir,[fname_out '_' datestr(now,'yyyymmdd')]));
		end
		save(fullfile(spikeDir,fname_out),'spikeTimesPerClust')
	catch
		fprintf('\nError: Failed to process %s. Skipping ...\n',spikeDir);
	end

end
