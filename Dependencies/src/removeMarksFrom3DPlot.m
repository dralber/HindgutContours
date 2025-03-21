function removeMarksFrom3DPlot()
    set(gca, 'XTick', [], 'XTickLabel', []);
    set(gca, 'YTick', [], 'YTickLabel', []);
    set(get(gca, 'XAxis'), 'Visible', 'off');
    set(get(gca, 'YAxis'), 'Visible', 'off');
    box off
    set(gca, 'ZTick', [], 'ZTickLabel', []);
    set(get(gca, 'ZAxis'), 'Visible', 'off');
end