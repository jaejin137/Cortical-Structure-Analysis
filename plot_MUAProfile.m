function [] = plot_MUAProfile(recordDate,dataName,depthPicked,timePicked,coordPos,figHandle,idx_prof)

	dir_resultData = fullfile('~','audiDeci','mat','audiRespCSD');
	load(fullfile(dir_resultData,dataName))
	%idx_rightDepth = find(probe_meanData.recordDepth == rightDepth)
	idx_rightDepth = find((probe_meanData.blockID == sprintf('%i_%i',recordDate,timePicked)).*(probe_meanData.recordDepth == depthPicked));
	nChannel = 24;

	% Plot rectMUA
	spacingRectMUA = 5;
	spacing = spacingRectMUA;
	figure(figHandle)
	%subplot_tight(15,15,225-15*(coordPos(2)-1)-(15-coordPos(1)),0.01)
	subplot_tight(7,7,idx_prof,0.02)
	%area([0 200],[-spacing/2 -spacing/2],-(nChannel+0.5)*spacing,'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.3)
	for chn = 1:nChannel % data channels
		yOffset = -chn*spacing;
		line([timeBin(1) timeBin(end)],[yOffset yOffset],'Color',[0.7 0.7 0.7],'LineWidth',.5); %plots baseline
		hold on
		z = probe_meanData.smooth_muaRect(chn,:)*1e6; % convert from V to uV
		plot(timeBin,z + yOffset,'k','LineWidth',1);  %plots RectMUA
		hold on
	end
	axis tight
	hold off;
	%xlabel('Time [ms]'), ylabel ([{'Amplitude [microvolts]'};{['Inter-Waveform Spacing = ',num2str(spacing)]}])
	cur_ax = gca;
	cur_ax.YTick = -((nChannel-1)*spacing):2*spacing:1;
	cur_ax.YTickLabel = num2str(((nChannel-1):-2:1)');
	%title('RectMUA')
	%hold off;
	set(gca,'Xticklabel',[])
	%set(gca,'Yticklabel',[])
	title(sprintf('[%i,%i]',coordPos(1)-8,coordPos(2)-8))
	set(gca,'FontSize',8)
	xlim([0 50])
	drawnow

end
