function [] = plotChromatogram(obj)
    
    % Calculate overlaps
    overlaps = zeros(3,1);
    overlaps(1) = sum(min(abs(obj.SimulationResults.solution.outlet(:, 2)), abs(obj.SimulationResults.solution.outlet(:, 3))));
    overlaps(2) = sum(min(abs(obj.SimulationResults.solution.outlet(:, 2)), abs(obj.SimulationResults.solution.outlet(:, 4))));
    overlaps(3) = sum(min(abs(obj.SimulationResults.solution.outlet(:, 3)), abs(obj.SimulationResults.solution.outlet(:, 4))));

    
    minTime = min(obj.SimulationResults.solution.time);
    maxTime = max(obj.SimulationResults.solution.time);
    timeVec = linspace(minTime,maxTime,1e4);
    pCut  = obj.SimulationResults.x(end-1:end);
    
    % Plot
    figure();
    hold on;    
    subplot(2,1,1);
    hold on
    y = spline(obj.SimulationResults.solution.time,obj.SimulationResults.solution.outlet(:, 2:end)',timeVec);
    plot(timeVec,y(1,:),'LineWidth',2,'color',[1,0,0;]');
    plot(timeVec,y(2,:),'LineWidth',2,'color',[0,0,0]');
    plot(timeVec,y(3,:),'LineWidth',2,'color',[0,0,1]');
    grid on;
    
    % Plot lines for start and end point
    ylim = get(gca,'ylim');
    plot([pCut(1),pCut(1)],ylim, 'LineStyle','-', 'Color', 'k','LineWidth',2);
	plot([pCut(2),pCut(2)],ylim, 'LineStyle','-', 'Color', 'k','LineWidth',2);
    set(gca, 'ylim', ylim);
    legend('Lys', 'Cyt', 'RNase','Location','Best');
    title(sprintf('1&2: %g  1&3: %g  2&3: %g  Y: %g  P: %g', [overlaps; obj.SimulationResults.Yield; obj.SimulationResults.Purity]));

    subplot(2,1,2);
    plot(obj.SimulationResults.solution.time, obj.SimulationResults.solution.inlet(:, 1),'LineWidth',2);
    grid on;
    title(sprintf('p1 %g p2 %g p3 %g SC %g TC %g', obj.SimulationResults.x));
    drawnow;

end