function h = Af_WindEnergyFig(h,width,varargin)
% Varargin(1) = FontSize
% varargin(2) = figure height

if numel(varargin) > 0
    figureFontSize = varargin{1};
else
    figureFontSize = 6.5;  %for wind energy
end


% set(h,'defaulttextinterpreter','latex');
% set(h, 'defaultAxesTickLabelInterpreter','latex');
% set(h, 'defaultLegendInterpreter','latex');

set(h,'defaulttextinterpreter','none');
set(h, 'defaultAxesTickLabelInterpreter','none');
set(h, 'defaultLegendInterpreter','none');

set(gca, 'defaultAxesFontName','Arial')
set(gca, 'defaultTextFontName','Arial');

%% Set Font Sizes

ha = get(gcf,'Children');
for ih = 1:length(ha)
    set(ha(ih), 'FontSize', figureFontSize);
    
    if strcmp(get(ha(ih),'type'),'axes')
        set(ha(ih), 'TitleFontSizeMultiplier', 1);
    end
end

%% Size Image

set(gcf,'Units','inches');
pos = get(h,'Position');
baseWidth = 7.5;

width = width * baseWidth;
if numel(varargin) > 1
    height = varargin{2};
else
    height = pos(4);
end


set(gcf,...
    'Units','inches',...
    'PaperSize',[width,height],...
    'PaperPosition',[0,0,width,height],...
    'Position',[5,2,width,height]);