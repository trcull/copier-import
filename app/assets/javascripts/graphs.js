
formatAsPercent = function (format, val) { 
            if (typeof val == 'number') { 
                    val = val*100; 
            if (!format) { 
                format = '%.1f'; 
            } 
            return $.jqplot.sprintf(format, val) + '%'; 
        } 
        else { 
            return String(val); 
        } 
};

everyNTickFormatter = function(format, val) {
	this.formatter.tickCount++;
	if (this.formatter.tickCount % 3 == 0){
		return val;
	} else {
		return " ";
	}
	
}
everyNTickFormatter.tickCount = -1;

draw_pct_cumulative_graph = function(div, dataSeries, seriesLabel, axisLabel, graphTitle) {
	if (!dataSeries[0] || dataSeries[0].length < 1) {
		$("#"+div).html("<span style=\"font-size:1.8em;\">Sorry, no data found yet, please come back later.</span>");
		$("#"+div).show();
	} else {
	    theGraph = $.jqplot(div, 
	    	dataSeries,
	    	{
	    		seriesDefaults: { renderer: $.jqplot.LineRenderer
	    			
	    		},
	    		axes: {
	    			xaxis: {
	    				showGridline: false,
	    				min: 0,
	    				label: graphTitle
	    			},
	    			yaxis: {
	    				min: 0,
	    				label: axisLabel,
	    				tickOptions: {
	    					showGridline: true,
	    					formatter: formatAsPercent
	    				}
	    			}
	    		},
	    		series: [{yaxis:'yaxis', label:seriesLabel, renderer: $.jqplot.LineRenderer}],
	    		highlighter: {
	    			showTooltip: true
	    		},
	    		cursor: {
	    			show: true,
	    			zoom: true,
	    			showTooltip: false
	    		}
	    		
	  		});
	  }
};




draw_cohort_pct_graph = function(div, dataSeries, seriesLabels, axisLabels, ticks, graphTitle) {
	if (!dataSeries[0] ||  dataSeries[0].length < 1) {
		$("#"+div).html("<span style=\"font-size:1.8em;\">Sorry, no data found yet, please come back later.</span>");
		$("#"+div).show();
	} else {
	  theGraph = $.jqplot(div, 
	    	dataSeries,
	    	{
	    		seriesDefaults: { renderer: $.jqplot.LineRenderer},
	    		/*
	    		legend: {
	                    show: true,
	                    placement: 'outsideGrid'
	                }, */
	    		axes: {
	    			xaxis: {
	    				showGridline: false,
	    				renderer: $.jqplot.CategoryAxisRenderer,
						tickRenderer: $.jqplot.CanvasAxisTickRenderer,
						
	                	tickOptions: {
	                    	angle: 30,
	                    	formatter: everyNTickFormatter// $.jqplot.DefaultTickFormatter
	                	},
	                    label: graphTitle
	                    //,ticks: ticks
	    			},
	    			yaxis: {
	    				min: 0,
	    				label: axisLabels[0],
	    				tickOptions: {
	    					showGridline: true,
	    					formatter: formatAsPercent
	    				}
	    			}
	    		},
	    		series: [{yaxis:'yaxis', label:seriesLabels[0], renderer: $.jqplot.LineRenderer}],
	    		highlighter: {
	    			showTooltip: true
	    		},
	    		cursor: {
	    			show: true,
	    			zoom: true,
	    			showTooltip: false
	    		}
	  		});
	}
};


draw_num_pct_cumulative_graph = function(div, dataSeries, seriesLabels, axisLabels, graphTitle) {
	if (!dataSeries[0] ||  dataSeries[0].length < 1) {
		$("#"+div).html("<span style=\"font-size:1.8em;\">Sorry, no data found yet, please come back later.</span>");
		$("#"+div).show();
	} else {
	    theGraph = $.jqplot(div, 
	    	dataSeries,
	    	{
	    		seriesDefaults: { renderer: $.jqplot.LineRenderer
	    			
	    		},
	    		axes: {
	    			xaxis: {
	    				showGridline: false,
	    				min: 0,
	    				label: graphTitle
	    			},
	    			yaxis: {
	    				min: 0,
	    				label: axisLabels[0],
	    				tickOptions: {
	    					showGridline: true,
	    					formatter: formatAsPercent
	    				}
	    			},
	    			y2axis: {
	    				min: 0,
	    				label: axisLabels[1],
	    				tickOptions: {
	    					showGridline: false,
	    					formatter: formatAsPercent
	    				}
	    			},
	    			y3axis: {
	    				min: 0,
	    				label: axisLabels[2],
	    				tickOptions: {
	    					showGridline: false
	    				}
	    			}
	    		},
	    		series: [{yaxis:'yaxis', label:seriesLabels[0], renderer: $.jqplot.LineRenderer}, //TODO: figure out why the BarRenderer looks funny and use it.
	    				{yaxis:'y2axis', label:seriesLabels[1]},
	    				{yaxis:'y3axis', label:seriesLabels[2]}
	    		],
	    		highlighter: {
	    			showTooltip: true
	    		},
	    		cursor: {
	    			show: true,
	    			zoom: true,
	    			showTooltip: false
	    		}
	    		
	  		});
	}
};

