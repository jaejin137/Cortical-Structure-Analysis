%% Generate templates for each monkey
resultMatPath = fullfile('~','audiDeci','mat','audiRespCSD');
dir_save_plot = fullfile('~','Casmiya','CSD_Template_Fig');
if ~exist(dir_save_plot,'dir')
	mkdir(dir_save_plot)
end
ifPlot = 'y';

load(fullfile('~','Casmiya','Laminae_AC.mat'));

nChannel = 24;

tmplt_indv = cell(size(laminar_ac_cassius,1)+size(laminar_ac_miyagi,1),3);

for m = 1:2
	if m == 1
		fprintf('\nProcessing data for Cassius...\n')
		targetMonk = 'C';
		laminar_ac = laminar_ac_cassius;
	else
		fprintf('\nProcessing data for Miyagi...\n')
		targetMonk = 'M';
		laminar_ac = laminar_ac_miyagi;
	end

	for recNum = 1:size(laminar_ac,1)
		sessTok = split(laminar_ac.RecordingSite(recNum),'_');
		targetSess = sessTok(1);
		drvTok = split(sessTok(2),'D');
		targetDrive = drvTok(2);
		depthTok = split(sessTok(4),'Depth');
		targetDepth = str2num(depthTok(2));

		targetMatFiles = dir(fullfile(resultMatPath,sprintf('Mr%s_%s_D%s_AC.mat',targetMonk,targetSess,targetDrive)));
					
		for k = 1:numel(targetMatFiles)
			csdData = load(fullfile(resultMatPath,targetMatFiles(k).name));
			recDep = sort(unique(csdData.probe_meanData.recordDepth));
			nRecordings = floor(length(csdData.probe_meanData.recordDepth)/nChannel);
			l = 1;
			allRecDep = [];
			for j = 1:numel(recDep)
				idx_recDepTmp = find(csdData.probe_meanData.recordDepth == recDep(j));
				for i = 1:floor(numel(idx_recDepTmp)/nChannel)
					idx_recDep(l,1:nChannel) = idx_recDepTmp(nChannel*(i-1)+1:nChannel*i);
					allRecDep(end+1,1) = recDep(j);
					l = l+1;
				end
			end
			% Plot CSD
			if ifPlot == 'y'
				if exist('h_csd')
					clf(h_csd)
				else
					h_csd = figure;
				end
				currPos = get(h_csd,'Position'); set(h_csd,'Position',[currPos(1),currPos(2),200*nRecordings,800]);
			end
			for j = 1:nRecordings
				CSD = csdData.probe_meanData.smooth_CSD(idx_recDep(j,end-23:end),:);
				% Find channel with maximum mean CSD
				CSD_rect = abs(CSD);
				CSD_rectMean = mean(CSD_rect,2);
				[maxRectMean,maxCh] = max(CSD_rectMean);
				if ifPlot == 'y'
					subplot(2,nRecordings,j)
					pcolor(csdData.timeBin,nChannel:-1:1,CSD(1:nChannel,:))
					shading interp;
					colormap jet;
					caxis([-2500 2500])
					set(gca,'YDir','normal','yTickLabel',nChannel:-2:0);
					xlabel('Time [ms]'); ylabel('electrode [ch]');
					if allRecDep(j) == targetDepth;
						title(sprintf('Depth=%i',allRecDep(j)),'Color','r')
					else
						title(sprintf('Depth=%i',allRecDep(j)))
					end
				end
		
				% Plot CSD
				spacing = 5*1.e3;
				if ifPlot == 'y'
					subplot(2,nRecordings,nRecordings+j)
				end
				for chn = 1:nChannel % data channels
					%yOffset = -chn*spacing;
					z = csdData.probe_meanData.smooth_CSD(idx_recDep(j,1)+chn-1,:); % convert from V to uV
					if allRecDep(j) == targetDepth && chn+1 == laminar_ac.LowerLamina3Sink(recNum)
						if m==1
							tmplt_cassius(recNum).LowerLamina3Sink = z;
						else
							tmplt_miyagi(recNum).LowerLamina3Sink = z;
						end
						lineColor = 'b';
						lineWidth = 2;
					elseif allRecDep(j) == targetDepth && chn+1 == laminar_ac.SupragranularSink(recNum)
						if m==1
							tmplt_cassius(recNum).SupragranularSink = z;
						else
							tmplt_miyagi(recNum).SupragranularSink = z;
						end
						lineColor = 'c';
						lineWidth = 2;
					elseif allRecDep(j) == targetDepth && chn+1 == laminar_ac.SupragranularSource(recNum)
						if m==1
							tmplt_cassius(recNum).SupragranularSource = z;
						else
							tmplt_miyagi(recNum).SupragranularSource = z;
						end
						lineColor = 'm';
						lineWidth = 2;
					else
						lineColor = 'k';
						lineWidth = 1;
					end
					if ifPlot == 'y'
						yOffset = -chn*spacing;
						line([csdData.timeBin(1) csdData.timeBin(end)],[yOffset yOffset],'Color',[0.7 0.7 0.7],'LineWidth',.5); %plots baseline
						hold on
						plot(csdData.timeBin,z + yOffset,lineColor,'LineWidth',lineWidth);  %plots CSD
					end
				end
				if ifPlot == 'y'
					axis tight
					hold off;
					cur_ax = gca;
					cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
					%cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
					cur_ax.YTickLabel = num2str((nChannel:-2:0)');
					xlabel('Time [ms]'); ylabel('electrode [ch]');
					if allRecDep(j) == targetDepth
						title(sprintf('Depth=%i',allRecDep(j)),'Color','r')
					else
						title(sprintf('Depth=%i',allRecDep(j)))
					end
				end
			end
			if ifPlot == 'y'
				fnameTok = split(targetMatFiles(k).name,'_');
				sgtitle(sprintf('%s-%s-%s',fnameTok{1:3}),'FontSize',20)
				drawnow
				print(h_csd,fullfile(dir_save_plot,sprintf('%s_%s_%s.png',fnameTok{1:3})),'-dpng','-r600')
			end
		end
	end
	if m==1
		tmplt_all = tmplt_cassius;
	else
		tmplt_all = tmplt_miyagi;
	end
	tmplt_LL3Snk_all = nan(size(tmplt_all,2),length(csdData.timeBin));
	tmplt_SGSnk_all = nan(size(tmplt_all,2),length(csdData.timeBin));
	tmplt_SGSrc_all = nan(size(tmplt_all,2),length(csdData.timeBin));
	for k = 1:size(tmplt_all,2)
		if ~isempty(tmplt_all(k).LowerLamina3Sink)
			tmplt_LL3Snk_all(k,:) = tmplt_all(k).LowerLamina3Sink;
		end
		if ~isempty(tmplt_all(k).SupragranularSink)
			tmplt_SGSnk_all(k,:) = tmplt_all(k).SupragranularSink;
		end
		if ~isempty(tmplt_all(k).SupragranularSource)
			tmplt_SGSrc_all(k,:) = tmplt_all(k).SupragranularSource;
		end
	end
	if m==1
		tmplt_cassius_LL3Snk = nanmean(tmplt_LL3Snk_all,1);
		tmplt_cassius_SGSnk = nanmean(tmplt_SGSnk_all,1);
		tmplt_cassius_SGSrc = nanmean(tmplt_SGSrc_all,1);
	else
		tmplt_miyagi_LL3Snk = nanmean(tmplt_LL3Snk_all,1);
		tmplt_miyagi_SGSnk = nanmean(tmplt_SGSnk_all,1);
		tmplt_miyagi_SGSrc = nanmean(tmplt_SGSrc_all,1);
	end
end
fprintf('\nGenerating templates done!\n\n')


