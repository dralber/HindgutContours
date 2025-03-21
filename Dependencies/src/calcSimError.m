function [embryo] = calcSimError(embryo, exportdir, name, iterations)
% Author: Daniel Alber
% Date: 3/19/2025
% Description: Assumes a nuclear diameter of 9.8um and simulated a jiggled
%               position within the supplied dimater for each point, then calculates
%               lengths, areas, and roundness of the contour with the jiggled points.
%               Must be careful to use the same hardcoded parameters (tolerance, number
%               of points in resampleContourToConstantSpeed) as in
%               fitContours(). Also plots first timepoint comparison of
%               contour metrics vs. measured along with statistics across
%               time.
%
% Inputs:
%   embryo   - Struct containing embryo data with fields smoothXAll,
%               smoothYAll, smoothZAll, contourIndices, thetas
%   exportdir - String specifying the directory to save the plots
%   name      - String specifying the filename suffix for saving
%   iterations-Number of simulated tracking experiments to run (1e3
%              suggested)
%
% Outputs:
%   embryo - Updated with fields:
%       meanSimCir - 5xt Mean simulated circumference
%       meanSimAr - 5xt Mean simulated areas
%       meanSimRo - 5xt mean simulated roundness
%       stdSimCir - 5xt std dev of simulated circumferences
%       stdSimAr  - 5xt " of  simulated areas
%       stdSimRo  - 5xt " of simulated roundnesses
%       normStdSimCir - 5xt of normalized sim. circ. by initial timepoint
%       normStdSimAr  - 5xt of normalized sim. Ar. by initial timepoint
%       normStdSimRo  - 5xt of normalized sim. Ro by iniital timepoint
%
% Dependencies:
%   progressbar
%   randomizePointsWithinDiameter
%   createSmoothCurve
%   extractClosedContour
%   resampleContourToConstantSpeed
%   calculateEnclosedArea
%   violinplot - from Matlab file exchange
%
% Usage:
%   embryo{1} = calcSimError(embryo{1}, 1e3)

[randX, randY, randZ] = randomizePointsWithinDiameter( ...
    9.8, embryo.smoothXAll, embryo.smoothYAll, embryo.smoothZAll, iterations); %9.8um diameter


%Arrays to store circum/area are contours x timepoints x iterations
simulatedCircumferences = zeros([size(embryo.contourIndices,1),size(randX,2),size(randX,3)]);
simulatedAreas = zeros(size(simulatedCircumferences));
simulatedContours = {};
progressbar
for k = 1:size(randX,3) %for each iteration
    progressbar(k/size(randX,3))
    if ~mod(k,50)
        disp("Finished iterations: " + int2str(k))
    end
    for j = 1:size(randX,2) % for each timepoint
        for i=1:length(embryo.contourIndices) %for each contour
            currIndices = embryo.contourIndices{i};
            [~,order] = sort(embryo.thetas(currIndices));

            contourPoints = [randX(currIndices,j,k), randY(currIndices,j,k), randZ(currIndices,j,k)];
            contourPointsSorted = contourPoints(order,:);
            fit3 = createSmoothCurve(contourPointsSorted,0.01,3);

            tolerance = 5; %tolerance for closing the contour
            fit3 = extractClosedContour(fit3, tolerance);
            constSpeedContour = resampleContourToConstantSpeed(fit3',500);

            %Circumference
            %[L,~,~] = contcurvature(constSpeedContour); %L is cumulative arclength, K is curvature vector, R is radius of curvature
            L = max(cumsum(sqrt(sum(diff(constSpeedContour).^2, 2)))); %About 2.6x faster than above method
            circumference = L;

            %Area
            DIndex = find(constSpeedContour(:,3)==max(constSpeedContour(:,3)),1);
            areaRiemann = calculateEnclosedArea(constSpeedContour,DIndex);

            simulatedCircumferences(i,j,k) = circumference;
            simulatedAreas(i,j,k) = areaRiemann;
            simulatedContours{i}{j,k} = constSpeedContour;
        end
    end
end
simulatedRoundness = simulatedAreas ./ (simulatedCircumferences .^ 2);

embryo.meanSimCir = mean(simulatedCircumferences,3);
embryo.meanSimAr = mean(simulatedAreas, 3);
embryo.meanSimRo = mean(simulatedRoundness,3);

embryo.stdSimCir = std(simulatedCircumferences,0,3);
embryo.stdSimAr = std(simulatedAreas,0,3);
embryo.stdSimRo = std(simulatedRoundness,0,3);

embryo.normStdSimCir = embryo.stdSimCir ./ embryo.contLengths(:,1);
embryo.normStdSimAr = embryo.stdSimAr ./ embryo.areas(:,1);
embryo.normStdSimRo = embryo.stdSimRo ./ (embryo.areas(:,1)./(embryo.contLengths(:,1).^2));

% Plots comparing simulated contours with measured
tp = 1; %selected timepoint for violin plots
currTpCircumferences = squeeze(simulatedCircumferences(:,tp,:));
xlabels = {"Contour 1", "Contour 2", "Contour 3", "Contour 4", "Contour 5"};
hFig = figure();
hFig.WindowState = 'normal';
hFig.Position = [50 50 500 500];
set(gcf, 'color', [1 1 1]);
violinplot(currTpCircumferences', xlabels,'ViolinColor',embryo.rgb_colors);
hold on
scatter([1,2,3,4,5],embryo.contLengths(:,tp),300,'kx')
title("Timepoint " + int2str(tp) + ", simulated vs real (X) contour circumference")
ylabel("Circumference (\mum)")
export_fig(fullfile(exportdir,name + "_SimulatedNoise_CircumferenceViolin_tp1"), ...
'-native','-pdf')

currTpAreas = squeeze(simulatedAreas(:,tp,:));
hFig = figure();
hFig.WindowState = 'normal';
hFig.Position = [50 50 500 500];
set(gcf, 'color', [1 1 1]);
violinplot(currTpAreas', xlabels,'ViolinColor',embryo.rgb_colors);
hold on
scatter([1,2,3,4,5],embryo.areas(:,tp),300,'kx')
title("Timepoint " + int2str(tp) + ", simulated vs real (X) contour areas")
ylabel("Area (\mum^2)")
export_fig(fullfile(exportdir,name + "_SimulatedNoise_AreaViolin_tp1"), ...
'-native','-pdf')

currTpRoundness = squeeze(simulatedRoundness(:,tp,:));
hFig = figure();
hFig.WindowState = 'normal';
hFig.Position = [50 50 500 500];
set(gcf, 'color', [1 1 1]);
violinplot(currTpRoundness', xlabels,'ViolinColor',embryo.rgb_colors);
hold on
scatter([1,2,3,4,5],embryo.areas(:,tp)./(embryo.contLengths(:,tp).^2),300,'kx')
title("Timepoint " + int2str(tp) + ", simulated vs real (X) contour roundness")
ylabel("Roundness")
export_fig(fullfile(exportdir,name + "_SimulatedNoise_RoundnessViolin_tp1"), ...
'-native','-pdf')

hFig = figure();
hFig.WindowState = 'normal';
hFig.Position = [50 50 1924 500];
set(gcf, 'color', [1 1 1]);
t = tiledlayout(3,1);

hold on
for i = 1:size(embryo.meanSimRo,1)
    nexttile(1)
    plot(1:1:size(embryo.meanSimAr,2),embryo.meanSimRo(i,:),'Color',embryo.rgb_colors(i,:),'LineWidth',2)
    hold on
    plot(1:1:size(embryo.meanSimAr,2), embryo.areas(i,:)./(embryo.contLengths(i,:).^2), ...
        '--','Color',embryo.rgb_colors(i,:),'LineWidth',2)
    title('Roundness, simulated noise vs experimental')
    xlabel('Timepoint')
    ylabel('Roundness')
    nexttile(3)
    plot(1:1:size(embryo.meanSimAr,2),embryo.meanSimAr(i,:),'Color',embryo.rgb_colors(i,:),'LineWidth',2)
    hold on
    plot(1:1:size(embryo.meanSimAr,2), embryo.areas(i,:),'--','Color',embryo.rgb_colors(i,:),'LineWidth',2)
    title('Enclosed Area, simulated noise vs experimental')
    xlabel('Timepoint')
    ylabel('Area (\mum^2)')
    nexttile(2)
    plot(1:1:size(embryo.meanSimAr,2),embryo.meanSimCir(i,:),'Color',embryo.rgb_colors(i,:),'LineWidth',2)
    hold on
    plot(1:1:size(embryo.meanSimAr,2), embryo.contLengths(i,:),'--','Color',embryo.rgb_colors(i,:),'LineWidth',2)
    title('Circumference, simulated noise vs experimental')
    xlabel('Timepoint')
    ylabel('Circumference (\mum)')
end
export_fig(fullfile(exportdir,name + "_MeasuredVsSimulatedOverTime"), ...
'-native','-pdf')

end