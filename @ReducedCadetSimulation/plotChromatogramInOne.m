function [] = plotChromatogramInOne(obj)
    
    % Calculate overlaps
    overlaps = zeros(3,1);
    overlaps(1) = sum(min(abs(obj.SimulationResults.solution.outlet(:, 2)), abs(obj.SimulationResults.solution.outlet(:, 3))));
    overlaps(2) = sum(min(abs(obj.SimulationResults.solution.outlet(:, 2)), abs(obj.SimulationResults.solution.outlet(:, 4))));
    overlaps(3) = sum(min(abs(obj.SimulationResults.solution.outlet(:, 3)), abs(obj.SimulationResults.solution.outlet(:, 4))));

    % Initialize important parameters
    minTime = min(obj.SimulationResults.solution.time);
    maxTime = max(obj.SimulationResults.solution.time);
    timeVec = linspace(minTime,maxTime,1e5);
    pCut  = obj.SimulationResults.x(end-1:end);
    
    % Define colors
    grayLin = [0,linspace(0.4,0.8,3)]';
    colorMap = ones(4,3).*repmat(grayLin,1,3);
    
    % Plot
    scaleTimeFactor = 1e3;
    figure();
    hold on;    
    y = spline(obj.SimulationResults.solution.time,obj.SimulationResults.solution.outlet(:, 2:end)',timeVec);
    timeVecPlot = timeVec/scaleTimeFactor;
    [AX,~,~] = plotyy(timeVecPlot,y(1:3,:),obj.SimulationResults.solution.time/scaleTimeFactor, obj.SimulationResults.solution.inlet(:, 1));
    ylabel(AX(1),'Outlet Protein Conc. [mM]')
    ylabel(AX(2),'Inlet Salt Conc. [mM]')
    xlabel(AX(1),'Time [{\cdot}10^3 s]')
    set(AX,'box','off','FontSize',20,'YColor','k','XLim',[0,(obj.bp.endTime+1e3)/scaleTimeFactor])
    AX(1).XAxis.TickLabelFormat = '%1.0g';
    
    %% Adjustments
    % Adjust range of view and ticks
    minY = min(min(y(1:3,:)));
    maxY = max(max(y(1:3,:)));
    stepSizeCons = 0.025;
    set(AX(1),'YLim',[minY,ceil(maxY/stepSizeCons)*stepSizeCons],'YTick',0:stepSizeCons:0.1);
    
    % Redefine Colors
    objects = findobj(gcf,'Type','Line');
    set(objects(1),'Color',colorMap(1,:),'LineWidth',2)
    set(objects(2),'Color',colorMap(2,:),'LineWidth',2)
    set(objects(3),'Color',colorMap(3,:),'LineWidth',2)
    set(objects(4),'Color',colorMap(4,:),'LineWidth',2)
    
    % Add legend
    legend('lys', 'cyt', 'rna','salt','Location','SouthEast');
    
    % Plot Cutting lines
    plot([pCut(1),pCut(1)]/scaleTimeFactor,ylim, 'LineStyle',':', 'Color', 'k','LineWidth',2);
    plot([pCut(2),pCut(2)]/scaleTimeFactor,ylim, 'LineStyle',':', 'Color', 'k','LineWidth',2);
    
    % Adjust size of image
    PaperPosition = [0,0,21*16/9,21];
    position = [1921,151,1680,974];
    set(gcf,'Position',position,'PaperPosition',PaperPosition)

end