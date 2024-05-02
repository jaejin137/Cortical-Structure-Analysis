%% Validate templates against some test data.

clearvars ch_match

ch_match(1).site = [];
ch_match(1).depth = [];
ch_match(1).LL3Snk = [];
ch_match(1).SGSnk = [];
ch_match(1).SGSrc = [];

for m = 1
	if m==1
		monkeyName = 'cassius';
		nameKey = 'MrC';
		recSite = laminar_ac_cassius.RecordingSite;
	else
		monkeyName = 'miyagi';
		nameKey = 'MrN';
		recSite = laminar_ac_miyagi.RecordingSite;
	end
	for l = 1:length(recSite)
		% Load test data
		sessTok = split(recSite(l),'_Depth');
		testFileName = sprintf('~/audiDeci/mat/audiRespCSD/%s_%s.mat',nameKey,sessTok{1});
		targetDepth = sessTok{2};
		csdDataTest = load(testFileName);
		%csdDataTest = load('~/audiDeci/mat/audiRespCSD/MrM_190415_D3_AC.mat');
		testChData = csdDataTest.probe_meanData.smooth_CSD(:,:);
		
		
		% Assign template
		if nameKey == 'MrC'
			tmplt2test_LL3Snk = tmplt_cassius_LL3Snk;
			tmplt2test_SGSnk = tmplt_cassius_SGSnk;
			tmplt2test_SGSrc = tmplt_cassius_SGSrc;
		else
			tmplt2test_LL3Snk = tmplt_miyagi_LL3Snk;
			tmplt2test_SGSnk = tmplt_miyagi_SGSnk;
			tmplt2test_SGSrc = tmplt_miyagi_SGSrc;
		end
		
		% Get cross-correlations between each channels and the templates.
		numChData = size(csdDataTest.probe_meanData,1);
		numDepth = numChData/24;
		clearvars xcorrTest
		for i = 1:numChData
			xcorrTest(i,1) = {xcorr(testChData(i,:),tmplt2test_LL3Snk,'normalized')};
			xcorrTest(i,2) = {xcorr(testChData(i,:),tmplt2test_SGSnk,'normalized')};
			xcorrTest(i,3) = {xcorr(testChData(i,:),tmplt2test_SGSrc,'normalized')};
		end
		
		% Plot
		xc_crit = .75;
		if exist('h_test')
			try
				close(h_test)
			end
		end
		clearvars h_test
		
		for j = 1:numDepth
			siteTok = split(recSite(l),'_Depth');
			ch_match(l+j).site = siteTok{1};
			ch_match(l+j).depth = csdDataTest.probe_meanData.recordDepth((j-1)*24+1);
			h_test(j) = figure;
			for i = 1:24
				subplot(6,4,i)
				for k = 1:3
					if max(xcorrTest{(j-1)*24+i,k}) >= xc_crit
						if k==1
							ch_match(l+j).LL3Snk(end+1) = i;
							lineColor = 'b';
						elseif k==2
							ch_match(l+j).SGSnk(end+1) = i;
							lineColor = 'c';
						else
							ch_match(l+j).SGSrc(end+1) = i;
							lineColor = 'm';
						end
						plot(xcorrTest{(j-1)*24+i,k},lineColor,'LineWidth',2);
						break
					else
						plot(xcorrTest{(j-1)*24+i,k},'k');
					end
				end
				ylim([-1,1]);
				title(sprintf('Ch=%i',i),'FontSize',14)
			end
			if csdDataTest.probe_meanData.recordDepth((j-1)*24+1) == str2num(targetDepth)
				fontColor = 'r';
			else
				fontColor = 'k';
			end
			sgtitle(sprintf('Depth = %i',csdDataTest.probe_meanData.recordDepth((j-1)*24+1)),'Color',fontColor,'FontSize',20)
			drawnow
		end
	end
end
