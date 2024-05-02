function [spikeTimesGoodClust] = save_good_clust_spike_times_pwd(spikeDir)

	%spikeDir = pwd;
	clustInfoDir = 'ClusterInfo';
	
	fname_out = 'spike_times_good_clust.mat';
	fname_out_basename = 'spike_times_good_clust';
	
	clustInfo = tdfread(fullfile(spikeDir,clustInfoDir,'cluster_info_new.tsv'));
	spikeClust = readNPY(fullfile(spikeDir,'spike_clusters.npy'));
	spikeTimes = readNPY(fullfile(spikeDir,'spike_times.npy'));
	
	
	try
		idx_row = 1;
		for idx_clust = 1:length(clustInfo.group)
			if contains(clustInfo.group(idx_clust,:),'good')
				spikeTimesGoodClust{idx_row,1} = clustInfo.id(idx_clust);
				spikeTimesGoodClust{idx_row,2} = spikeTimes(find(spikeClust==clustInfo.id(idx_clust)));
				idx_row = idx_row+1;
			end
		end
		fprintf('\nSaving spike times for %s ...\n',spikeDir);
		if exist(fullfile(spikeDir,clustInfoDir,fname_out))
			movefile(fullfile(spikeDir,clustInfoDir,fname_out),fullfile(spikeDir,clustInfoDir,[fname_out_basename '_' datestr(now,'yyyymmdd') '.mat']));
		end
		save(fullfile(spikeDir,clustInfoDir,fname_out),'spikeTimesGoodClust')
	catch
		fprintf('\nError: Failed to process %s. Skipping ...\n',spikeDir);
	end
	
end
