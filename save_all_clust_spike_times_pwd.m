function [spikeTimesAllClust] = save_all_clust_spike_times(spikeDir)

	%spikeDir = pwd;
	clustInfoDir = 'ClusterInfo';
	
	fname_out = 'spike_times_all_clust.mat';
	fname_out_basename = 'spike_times_all_clust';
	
	clusterInfo = struct2table(tdfread(fullfile(spikeDir,clustInfoDir,'cluster_info_new.tsv')));
	spikeClust = readNPY(fullfile(spikeDir,'spike_clusters.npy'));
	spikeTimes = readNPY(fullfile(spikeDir,'spike_times.npy'));
	
	clust_uniq = sort(unique(spikeClust));
	
	for idx_clust = 1:length(clust_uniq)
		spikeTimesAllClust{idx_clust,1} = clust_uniq(idx_clust);
		spikeTimesAllClust{idx_clust,2} = spikeTimes(find(spikeClust==clust_uniq(idx_clust)));
		if contains(clusterInfo.group(idx_clust,:),'    ')
			spikeTimesAllClust{idx_clust,3} = 'unsorted';
		else
			spikeTimesAllClust{idx_clust,3} = clusterInfo.group(idx_clust,:);
		end
	end
	
	fprintf('\nSaving all spike times for %s ...\n',spikeDir);
	
	if exist(fullfile(spikeDir,clustInfoDir,fname_out))
		movefile(fullfile(spikeDir,clustInfoDir,fname_out),fullfile(spikeDir,clustInfoDir,[fname_out_basename '_' datestr(now,'yyyymmdd') '.mat']));
	end
	save(fullfile(spikeDir,clustInfoDir,fname_out),'spikeTimesAllClust')

end
