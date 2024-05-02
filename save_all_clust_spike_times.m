%function [spikeTimesAllClust] = save_all_clust_spike_times(sessDate, areaName, dir_a1, dir_belt)
function [spikeTimesAllClust] = save_all_clust_spike_times(sessDate, areaName)

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
	
	fname_out = 'spike_times_all_clust.mat';
	fname_out_basename = 'spike_times_all_clust';
	
	%try
		clusterGroup = struct2table(tdfread('cluster_group_new.tsv'));
		spikeClust = readNPY(fullfile(spikeDir,'spike_clusters.npy'));
		spikeTimes = readNPY(fullfile(spikeDir,'spike_times.npy'));
		clust_uniq = sort(unique(spikeClust));
		for idx_clust = 1:length(clust_uniq)
			spikeTimesAllClust{idx_clust,1} = clust_uniq(idx_clust);
			spikeTimesAllClust{idx_clust,2} = spikeTimes(find(spikeClust==clust_uniq(idx_clust)));
			spikeTimesAllClust{idx_clust,3} = clusterGroup.group(idx_clust,:);
		end
		fprintf('\nSaving all spike times for %s ...\n',spikeDir);
		if exist(fullfile(spikeDir,fname_out))
			movefile(fullfile(spikeDir,fname_out),fullfile(spikeDir,[fname_out_basename '_' datestr(now,'yyyymmdd') '.mat']));
		end
		save(fullfile(spikeDir,fname_out),'spikeTimesAllClust')
	%catch
	%	fprintf('\nError: Failed to process %s. Skipping ...\n',spikeDir);
	%end
end

