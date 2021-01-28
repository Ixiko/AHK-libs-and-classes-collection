function Chart(width, height, margin) {
	if(typeof margin === "object"){
		this.margin = margin;
	} else {
		margin = margin < 40 ? 40 : margin;
		this.margin = {top: margin, left: margin, bottom: margin, right: margin};
	}
	this.SvgWidth = width; this.SvgHeight = height;
	this.width = width - this.margin.left - this.margin.right;
	this.height = height - this.margin.top - this.margin.bottom;
	this.svg = d3.select("svg")
		.attr("width", width)
		.attr("height", height);
	this.ID = 0;
	
	var filter = this.svg.append("filter").attr("id", "dropShadow");
		filter.append("feGaussianBlur").attr("in", "SourceAlpha").attr("stdDeviation", 3);
		//filter.append("feOffset").attr("dx", 0).attr("dy", 0);
	var feMerge = filter.append("feMerge");
		feMerge.append("feMergeNode");
		feMerge.append("feMergeNode").attr("in", "SourceGraphic");
	
	this.Curves = {	Ba:	 d3.curveBasis,
					Bu:	 d3.curveBundle,
					Car: d3.curveCardinal,
					Cat: d3.curveCatmullRom,
					L:	 d3.curveLinear,
					MX:	 d3.curveMonotoneX,
					MY:	 d3.curveMonotoneY,
					N:	 d3.curveNatural,
					S:	 d3.curveStep,
					SA:	 d3.curveStepAfter,
					SB:	 d3.curveStepBefore};
	
	/*this.svg.append("polygon")
		.attr("fill-rule", "evenodd")
		.attr("fill", "#FF00FF")
		.attr("opacity", "0.5"); */
	
	this.Axes = new Axes(this.width, this.height, this.margin);
	this.Data = new Data();
	
	this.Charts = this.svg.append("g")
		.attr("id", "charts");
	
	this.Legend = this.svg.append("g")
		.attr("id", "legend")
		.attr("opacity", 0)
		.on("mouseup",	 function(){plot.Legend.move = false;})
		.on("mousedown", function(){plot.Legend.move = true;})
		.on("mousemove", function(){
			if(plot.Legend.move){
				plot.Legend.attr("transform", "translate(" + (event.clientX - plot.Legend.width/2) + "," + (event.clientY - plot.Legend.height/2) + ")");
			}
		});
	
	this.Legend.rect = this.Legend.append("rect")
		.attr("stroke", "black")
		.attr("fill", "lightgrey");
	
	this.Legend.move = false;
	
	this.Update = function(width, height, margin){
		
		this.SvgWidth  = width  != undefined ? width  : this.SvgWidth;
		this.SvgHeight = height != undefined ? height : this.SvgHeight;
		
		if(typeof margin === "object"){
			this.margin = margin;
		} else if(margin != undefined) {
			margin = margin < 40 ? 40 : margin;
			this.margin = {top: margin, left: margin, bottom: margin, right: margin};
		}
		
		this.width = this.SvgWidth - this.margin.left - this.margin.right;
		this.height = this.SvgHeight - this.margin.top - this.margin.bottom;
		
		this.svg.attr("width",  this.SvgWidth);
		this.svg.attr("height", this.SvgHeight);
		
		/* this.svg.select("polygon")
			.attr("points", toPoints([[0, 0]
									, [this.width + this.margin.left + this.margin.right, 0]
									, [this.width + this.margin.left + this.margin.right, this.height + this.margin.top + this.margin.bottom]
									, [0, this.height + this.margin.top + this.margin.bottom]
									, [0, 0]
									, [this.margin.left, this.margin.top]
									, [this.width + this.margin.left, this.margin.top]
									, [this.width + this.margin.left, this.height + this.margin.top]
									, [this.margin.left, this.height + this.margin.top]
									, [this.margin.left, this.margin.top]])
			); */
		
		this.Axes.Update(this.width, this.height, this.margin);
	};
	
	this.RemovePath = function(index){
		if(index == undefined) {
			this.svg.selectAll("#charts > .graph").remove();
		} else {
			var graphs = this.svg.selectAll("#charts > .graph");
			index = index < 0 ? graphs._groups[0].length + index : index;
			graphs.select(function(d, i){return i == index ? this : null;}).remove();
		}
	};
	
	this.SetAxes = function(xmin, xmax, ymin, ymax, Boxed) {
		xmin = xmin == undefined ? this.Axes.x.min() : xmin;
		xmax = xmax == undefined ? this.Axes.x.max() : xmax;
		ymin = ymin == undefined ? this.Axes.y.min() : ymin;
		ymax = ymax == undefined ? this.Axes.y.max() : ymax;
		this.Axes.Set([xmin, xmax], [ymin, ymax], Boxed);
	};
	
	this.NewGroup = function(ID, InterAct){
		var g = this.Charts.append("g")
			.attr("id", InterAct ? ID + "-" + this.ID : ID)
			.attr("class", "graph")
			.attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");
		if(InterAct){
			ID = "#" + ID + "-" + this.ID;
			g.on("mouseenter", function(){d3.select(ID + " > #circles").attr("opacity", 1);
										  d3.select(ID + " > path").attr("filter", "url(#dropShadow)");});
			g.on("mouseleave", function(){d3.select(ID + " > #circles").attr("opacity", 0);
										  d3.select(ID + " > path").attr("filter", null);});
			this.ID += 1;
		}
		return g;
	};
	
	this.LinePlot = function(FunX, FunY, Colour, Width, Resolution, Range, Optimize) {
		if(!this.Axes.Exist){
			this.SetAxes(-100, 100, -100, 100)
		}
		var Axis = Range;
		if(!Array.isArray(Range)){
			Range = [(Range == "x" ? this.Axes.x.min() : this.Axes.y.min()), (Range == "x" ? this.Axes.x.max() : this.Axes.y.max())];
		}
		if(Resolution == 0){
			var Resolution = (Math.abs(Range[0]) + Math.abs(Range[1])) / 20000;
		}
		var Data = this.Data.FromFunction(FunX, FunY, Range[0], Range[1], Resolution, Optimize, Axis);
		var line = this.NewGroup("line-graph", true);
		
		this.DrawLine(line, Data, Colour, Width);
		this.DrawDots(line, Data.filter(function(val){return val != null;}), 3, "#000000", 0);
	};
	
	this.LinePlot2 = function(LstX, LstY, Colour, Width, ScaleAxes, Curve) {
		var Data = d3.zip(LstX, LstY);
		
		if(ScaleAxes || !this.Axes.Exist){
			this.Axes.ScaleToData(Data);
		} else {
			Data = Data.filter(this.Axes.LimitToOne);
		}
		
		var line = this.NewGroup("line-graph", true);
		
		this.DrawLine(line, Data, Colour, Width, undefined, Curve);
		
		this.DrawDots(line, Data.filter(function(val){return val != null;}), 3, "#000000", 0);
	};
	
	this.ScatterPlot = function(LstX, LstY, Colour, Size, Opacity, ScaleAxes, Group) {
		Group = Group ? Group : this.NewGroup("graph");
		
		var Data = d3.zip(LstX, LstY);
		
		if(ScaleAxes || !this.Axes.Exist){
			this.Axes.ScaleToData(Data);
		} else {
			Data = Data.filter(this.Axes.LimitToOne);
		}
		
		this.DrawDots(Group, Data, Size, Colour, Opacity);
	};
	
	this.BarPlot = function(Axis, Data, Colour, Width, Opacity) {
		var Group = this.NewGroup("graph");
		
		this.DrawStacks(Group, Axis, Data, d3.stack(), Width, Colour, Opacity);
	};
	
	this.Tree = function(Data) {
		var Group = this.NewGroup("graph");
		
		this.DrawTree(Group, ObjToHierarchy(Data, ""));
	};
	
	this.DrawLine = function(Group, Data, Colour, Width, Opacity, Curve){
		if(Data.length < 1){
			return;
		}
		
		Width   = Width   == undefined ? 3 : Width;
		Opacity = Opacity == undefined ? 1 : Opacity;
		Colour  = Colour  == undefined ? "#0000FF" : Colour;
		Group   = Group   == undefined ? this.svg : Group;
		Curve   = Curve   == undefined ? d3.curveCatmullRom : this.Curves[Curve];
		
		Group.datum(Data);
		
		var line = d3.line()
			.curve(Curve)
			.defined(function(d){return d;})
			.x(this.Axes.GetXval)
			.y(this.Axes.GetYval);
		
		Group.append("path")
			.attr("class", "line")
			.attr("d", line)
			.attr("fill", "none")
			.attr("stroke", Colour)
			.attr("stroke-width", Width);
	};
	
	this.DrawDots = function(Group, Data, Radius, Colour, Opacity){
		if(Data.length < 1){
			return;
		}
		
		Radius  = Radius  == undefined ? 3 : Radius;
		Opacity = Opacity == undefined ? 1 : Opacity;
		Colour  = Colour  == undefined ? "#0000FF" : Colour;
		Group   = Group   == undefined ? this.svg : Group;
		
		var g = Group.append("g")
			.attr("id", "circles")
			.attr("fill", Colour)
			.attr("opacity", Opacity);
		
		g.selectAll("dot")
			.data(Data)
			.enter().append("circle")
				.attr("r", Radius)
				.attr("cx", this.Axes.GetXval)
				.attr("cy", this.Axes.GetYval);
	};
	
	this.DrawStacks = function(Group, Axis, Data, Stack, Width, Colour, Opacity){
		if(Data.length < 1){
			return;
		}
		
		Data = Data.map(function(o,i){o.splice(0, 0, i+1); return o;});
		
		var rectPerBar = Data[0].length - 1;
		var numOfColours = (rectPerBar == 1) ? Data.length : rectPerBar;
		
		Axis	= Axis	  == undefined ? "x" : Axis;
		Width	= Width	  == undefined ?  3  : Width;
		Opacity = Opacity == undefined ?  1  : Opacity;
		Colour  = Colour  == undefined ? GetDiffrentColours(numOfColours) : Colour;
		Group   = Group   == undefined ? this.svg : Group;
		
		bool = Axis == "x";
		
		Group.selectAll(".serie")
			.data(Stack.keys(d3.range(1, rectPerBar + 1))(Data))
			.enter().append("g")
				.attr("class", "serie")
				.attr("fill", function(d) {return Colour[d.index];})
				.attr("opacity", Opacity)
				.attr("transform", "translate(" + (bool ? -Width/2 : 0) + "," + (bool ? 0 : -Width/2) + ")")
			.selectAll("rect")
			.data(function(d){return d;})
			.enter().append("rect")
				.attr("x", function(d) {return plot.Axes.x( bool ? d.data[0] : (d[1] > 0 ? d[0] : d[1]));})
				.attr("y", function(d) {return plot.Axes.y(!bool ? d.data[0] : (d[1] > 0 ? d[1] : d[0]));})
				.attr("height", bool ? function(d) {return Math.abs(plot.Axes.y(d[0]) - plot.Axes.y(d[1]));} : Width)
				.attr("width", !bool ? function(d) {return Math.abs(plot.Axes.x(d[0]) - plot.Axes.x(d[1]));} : Width)
				.attr("fill", function(d) {return (rectPerBar == 1) ? Colour[d.data[0] - 1] : null;});
	};
	
	this.DrawTree = function(Group, Data){
		if(Data.length < 1){
			return;
		}
		
		Group = Group == undefined ? this.svg : Group;
		
		var root = d3.hierarchy(Data);
		
		var tree = d3.tree()
			.size([this.height, this.width - 100]);
		
		var link = Group.selectAll(".link")
			.data(tree(root).links())
			.enter().append("path")
				.attr("class", "link")
				.attr("opacity", 0.5)
				.attr("d", d3.linkHorizontal()
					.x(function(d) { return d.y; })
					.y(function(d) { return d.x; }));
				
		var node = Group.selectAll(".node")
			.data(root.descendants())
			.enter().append("g")
				.attr("class", function(d) { return "node" + (d.children ? " node--internal" : " node--leaf")
														   ; }) // + (d.data.id.search("¤") > -1 ? " node--word" : "")
				.attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

		node.append("circle")
			.attr("r", 2.5); // function(d) { return d.data.id.search("¤") > -1 ? 3.5 : 2.5; }

		node.append("text")
			.attr("dy", 3)
			.attr("x", function(d) { return d.children ? -8 : 8; })
			.text(function(d) { return d.data.id.replace("¤", ""); }); // 
	};
	
	this.MakeLegend = function(Legend, Colour){
		if(Legend == undefined || Legend.length < 1){
			this.Legend.attr("opacity", 0);
			return;
		} else {
			Colour = Colour == undefined ? GetDiffrentColours(Legend.length) : Colour;
			this.Legend.selectAll(".entry").remove();
			
			this.Legend.rect.attr("height", 0);
			this.Legend.rect.attr("width", 0);
			
			for(index in Legend){
				var entry = this.Legend.append("g")
					.attr("class", "entry");
				entry.append("text")
					.attr("y", index * 20 + 21)
					.attr("x", -26)
					.attr("text-anchor", "end")
					.text(Legend[index]);
				entry.append("rect")
					.attr("x", -20)
					.attr("y", index * 20 + 6)
					.attr("width", 18)
					.attr("height", 18)
					.attr("fill", Colour[index]);
			}
			var bbox = document.getElementById("legend").getBBox();
			
			this.Legend.width  = bbox.width + 7;
			this.Legend.height = Legend.length * 20 + 6 + 4;
			
			this.Legend.rect.attr("height", this.Legend.height);
			this.Legend.rect.attr("width",  this.Legend.width);
			
			this.Legend.selectAll(".entry").attr("transform", "translate(" + (bbox.width + 5) + "," + 0 + ")");
			
			this.Legend.attr("transform", "translate(" + (this.width - bbox.width) + "," + 0 + ")");
			this.Legend.attr("opacity", 1);
		}
	};
}

function Axes(width, height, margin){
	this.width = width;
	this.height = height;
	this.boxed = undefined;
	this.x = Range("x", 0, width);
	this.y = Range("y", height, 0);
	this.xAxis = d3.axisBottom(this.x);
	this.yAxis = d3.axisLeft(this.y);
	this.Exist = false;
	
	this.axes = d3.select("svg").append("g")
		.attr("id", "axes")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	
	this.xGrid = new Grid("x", this.axes, this.x, this.boxed);
	this.yGrid = new Grid("y", this.axes, this.y, this.boxed);
	
	this.NewAxis = function(ID){
		this.axes.append("text")
			.attr("id", "Label-" + ID)
			.attr("class", "Label")
			.attr("text-anchor", "middle")
			.attr("dy", (ID == "x" ? 25 : -15));
		this.axes.append("g")
			.attr("id", "axis-" + ID)
			.attr("class", "axis")
			.on("mouseenter", function(){d3.select("#axis-" + ID + " > path").attr("filter", "url(#dropShadow)");})
			.on("mouseleave", function(){d3.select("#axis-" + ID + " > path").attr("filter", null);});
	};
	
	this.NewAxis("x");
	this.NewAxis("y");
	
	this.DomAxisX = document.getElementById("axis-x");
	this.DomAxisY = document.getElementById("axis-y");
	
	this.HideAxes = function(bool){
		if(bool != undefined){
			this.axes.attr("opacity", bool);
		}
	}
	
	this.SetLabels = function(xLabel, yLabel){
		if(xLabel != undefined){
			this.axes.select("#Label-x").text(xLabel);
		}
		if(yLabel != undefined){
			this.axes.select("#Label-y").text(yLabel);
		}
		this.PlaceLabel();
	};
	
	this.PlaceLabel = function(){
		if(this.boxed){
			var ticktextX = this.DomAxisX.getElementsByTagName("text");
			var ticktextY = this.DomAxisY.getElementsByTagName("text");
			if(ticktextX.length > 0){
				var Label = document.getElementById("Label-x").getBBox();
				this.axes.select("#Label-x").attr("dy", 10 + Label.height + ticktextX[ticktextX.length/2].getBBox().height);
			}
			if(ticktextY.length > 0){
				this.axes.select("#Label-y").attr("dy", -10 + ticktextY[ticktextY.length/2].getBBox().x);
			}
		} else {
			this.axes.select("#Label-x").attr("dy",  25);
			this.axes.select("#Label-y").attr("dy", -15);
		}
	};
	
	this.Update = function(width, height, margin){
		this.width = width;
		this.height = height;
		this.axes.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
		this.x.range([0, width]);
		this.y.range([height, 0]);
	};
	
	this.Set = function(xlst, ylst, boxed){
		this.boxed = boxed == undefined ? this.boxed : boxed == true;
		this.x.ChangeDomain(xlst);
		this.y.ChangeDomain(ylst);
		this.Axis("x");
		this.Axis("y");
		this.xGrid.Update(-this.height, "0," + this.height, this.boxed);
		this.yGrid.Update(-this.width, "0,0", this.boxed);
		this.PlaceLabel();
		this.Exist = true;
	};
	
	this.Grid = function(OnOff){
		this.axes.selectAll(".grid").attr("opacity", OnOff);
	};
	
	this.SetGrid = function(xory, major, minor, colour, dasharray){
		if(xory == "x" || xory == ""){
			this.xGrid.Set(major, minor, colour, dasharray);
			this.Axis("x");
		}
		if(xory == "y" || xory == ""){
			this.yGrid.Set(major, minor, colour, dasharray);
			this.Axis("y");
		}
	};
	
	this.Axis = function(xory){
		var axis = this.axes.select("#axis-" + xory);
		axis.attr("transform", "translate(" + (xory == "x" ? ("0," + (this.boxed ? this.y(this.y.start()) : (this.y.zero ? this.y(0) : this.y(this.y.mid()))) + ")")
														   : ((this.boxed ? "0" : (this.x.zero ? this.x(0) : this.x(this.x.mid()))) + ",0)"))
		);
		axis.call((xory === "x" ? this.xAxis.tickValues(this.x.GetTicks()) : this.yAxis.tickValues(this.y.GetTicks())));
		
		this.axes.select("#Label-" + xory).attr("transform", "translate(" + (xory == "x" ? (this.width / 2 + "," + this.height + ")")
																						 : ("0," + this.height / 2 + ")rotate(-90)"))
		);
	};
	
	this.ScaleToData = function(data){
		if(data.length < 1){
			return;
		}
		this.Set(d3.extent(data, function(d){return d[0];}), d3.extent(data, function(d){return d[1];}));
	};
	
	this.GetXval = function(d){return plot.Axes.x(d[0]);};
	this.GetYval = function(d){return plot.Axes.y(d[1]);};
	
	this.LimitToOne = function(a){return (plot.Axes.x.min() <= a[0] && a[0] <= plot.Axes.x.max() && plot.Axes.y.min() <= a[1] && a[1] <= plot.Axes.y.max());};
	this.LimitToTwo = function(x, y){return (plot.Axes.x.min() <= x && x <= plot.Axes.x.max() && plot.Axes.y.min() <= y && y <= plot.Axes.y.max());};
}

var Range = function(type, start, end) {
	var range = d3.scaleLinear();
	range.type = type;
	range.range([start, end]);
	range.AproxNumOfTicks = 10;
	range.ChangeDomain = function(Lst){
		this.domain(Lst);
		this.zero = (d3.min(this.domain()) <= 0 && 0 <= d3.max(this.domain()));
	};
	range.GetTicks = function(){
		if(Array.isArray(this.AproxNumOfTicks)){
			return this.AproxNumOfTicks;
		}
		return this.ticks(this.AproxNumOfTicks);
	};
	range.min = function(){return d3.min(this.domain());};
	range.mid = function(){return Math.round(d3.mean(this.domain()));};
	range.max = function(){return d3.max(this.domain());};
	
	range.start	= function(){return this.domain()[0];};
	range.end	= function(){return this.domain()[1];};
	return range;
};

var Grid = function(id, axes, range, Boxed) {
	this.ID = id;
	this.Grid = axes.append("g")
		.attr("id", "grid-" + this.ID)
		.attr("class", "grid")
		.attr("opacity", 0)
		.attr("stroke", "lightgrey")
		.attr("stroke-dasharray", "5");
	this.Range = range;
	this.NumOfMajorTicks = 10;
	this.NumOfMinorTicks = 0;
	this.Boxed = Boxed;
	
	this.Set = function(major, minor, colour, dasharray){
		this.NumOfMajorTicks = major == undefined ? this.NumOfMajorTicks : major;
		this.Range.AproxNumOfTicks = this.NumOfMajorTicks;
		this.NumOfMinorTicks = minor == undefined ? this.NumOfMinorTicks : minor;
		this.Grid.attr("stroke", (colour == undefined ? "lightgrey" : colour));
		this.Grid.attr("stroke-dasharray", (dasharray == undefined ? "5" : dasharray));
		this.Grid.call(this.GetAxis());
		this.CleanUp();
	};
	
	this.Update = function(tickSize, translate, Boxed){
		this.Boxed = Boxed;
		this.tickSize = tickSize;
		this.Grid.attr("transform", "translate(" + translate + ")");
		this.Grid.call(this.GetAxis());
		this.CleanUp();
	};
	
	this.CleanUp = function(){
		this.Grid.selectAll(".tick").selectAll("line").attr("stroke", null);
		this.Grid.selectAll("text").remove();
		this.Grid.select("path").remove();
	};
	
	this.GetAxis = function(){
		return (this.ID == "x" ? d3.axisBottom(this.Range) : d3.axisLeft(this.Range))
					.tickFormat("")
					.tickSizeOuter(0)
					.tickSize(this.tickSize)
					.tickValues(this.GetTicks());
	};
	
	this.GetTicks = function(){
		var ticks = this.Range.GetTicks();
		var minorticks = [];
		
		for(i = 0; i < ticks.length; i++){
			var step = Math.abs((ticks[i] - ticks[i+1]) / (this.NumOfMinorTicks + 1));
			minorticks = minorticks.concat(d3.range(ticks[i], ticks[i+1], (ticks[i] < ticks[i+1]) ? step : - step));
		}
		
		minorticks.push(ticks[ticks.length - 1])
		var index = minorticks.indexOf(this.Boxed ? this.Range.start() : (this.Range.zero ? 0 : this.Range.mid()));
		if(index != -1){
			minorticks.splice(index, 1);
		}
		return minorticks;
	};
};

function Data() {
	this.Init = function(){
		this.x = plot.Axes.x; this.xmin = this.x.min(); this.xmid = this.x.mid(); this.xmax = this.x.max();
		this.y = plot.Axes.y; this.ymin = this.y.min(); this.ymid = this.y.mid(); this.ymax = this.y.max();
	};
	this.LimitToOne = function(a){return (this.xmin <= a[0] && a[0] <= this.xmax && this.ymin <= a[1] && a[1] <= this.ymax);};
	this.LimitToTwo = function(x, y){return (this.xmin <= x && x <= this.xmax && this.ymin <= y && y <= this.ymax);};
	
	this.FromFunction = function(FunX, FunY, from, to, Resolution, Optimize, Axis){
		Axis = Axis == "y" ? false : true;
		
		this.Init();
		var bool = true, poslst = [], old = 0, old2 = 5, xmin = this.x.min(), xmax = this.x.max(), ymin = this.y.min(), ymax = this.y.max();
		var step = Math.abs((from - to) / Resolution); //(Math.abs(from) + Math.abs(to)) / Resolution;
		var varX, varY;
		if(!Optimize){
			data = d3.range(from, to, step).map(function(x){
				varX = eval(FunX); varY = eval(FunY);
				if(ymin <= varY && varY <= ymax && xmin <= varX && varX <= xmax){
					return [varX, varY];
				}
			});
		} else {
			data = d3.range(from, to, step).map(function(x, index){
				varX = eval(FunX); varY = eval(FunY);
				if(ymin <= varY && varY <= ymax && xmin <= varX && varX <= xmax){
					if(bool){
						poslst.push(index);
						old = Axis ? varY : varX; bool = false;
					} else if((old2 < old && old > (Axis ? varY : varX)) || (old2 > old && old < (Axis ? varY : varX))) {
						poslst.push(index - 1);
					}
					old2 = old; old = Axis ? varY : varX;
					return [varX, varY];
				} else {
					if(!bool){
						poslst.push(index - 1);
						bool = true;
					}
				}
			});
			
			poslst.push(data.length - 1);
			poslst = poslst.reverse();
			
			var extremum, start, end;
			for(i in poslst) {
				start = data[poslst[i]-1] != null ? data[poslst[i]-1][Axis ? 0 : 1] : from + (poslst[i]-1)*step;
				end   = data[poslst[i]+1] != null ? data[poslst[i]+1][Axis ? 0 : 1] : from + (poslst[i]+1)*step;
				
				extremum = d3.range(start, end, step / 10).map(
					function(x){
						varX = eval(FunX); varY = eval(FunY);
						if(ymin <= varY && varY <= ymax && xmin <= varX && varX <= xmax){
							return [varX, varY];
						};
					}).filter(function(val){return val != null;});
				
				data.splice.apply(data, [poslst[i]-1 > 0 ? poslst[i]-1 : 0, 2].concat(extremum));
			}
		}
		var x = to;
		varX = eval(FunX); varY = eval(FunY);
		if(ymin <= varY && varY <= ymax && xmin <= varX && varX <= xmax){
			data.push([varX, varY]);
		}
		return data;
	};
}

var GetDiffrentColours = function(num){
	return d3.range(0, 360, Math.round(360 / num)).map(function(v,i){return d3.hsl(v, 1, (i % 2) ? 0.4 : 0.6);});
}

var time = function(){return new Date().getTime();};

var PrintPointArray = function(array){
	msg = "[";
	for (i in array){
		msg += (array[i] != null ? "[" + array[i][0] + ", " + array[i][1] + "], " : "");
	}
	alert(msg + "]");
}

var IsDefined = function(val){
	return val != undefined ? val : undefined;
}

var toPoints = function(array){
	var len = array.length, res = "";
	for(i = 0; i < len; i++){
		res += array[i][0] + "," + array[i][1] + " ";
	}
	return res.substr(0, res.length - 1);
}

var Demo = function(text){
	if(document.getElementById("demo") == null){
		p = document.createElement("p");
		p.id = "demo";
		document.body.insertBefore(p, document.body.childNodes[0]);
	}
	document.getElementById("demo").innerHTML = text;
}

var ObjToHierarchy = function(obj, key) {
	var Hierarchy = {"id" : key};
	if((typeof obj === "string" || typeof obj === "number") && obj !== "") {
		Hierarchy["children"] = [{"id" : obj}];
	} else {
		Hierarchy["children"] = [];
		
		if(Array.isArray(obj)) {
			for(i in obj) {
				if((typeof obj[i] === "string" || typeof obj[i] === "number") && obj[i] !== "") {
					Hierarchy["children"].push({"id" : obj[i]});
				} else {
					Hierarchy["children"].push(ObjToHierarchy(obj[i], ""));
				}
			}
		} else {
			for(i in obj) {
				Hierarchy["children"].push(ObjToHierarchy(obj[i], i));
			}
		}
	}
	return Hierarchy;
}

var ObjToString = function(obj) {
	if(typeof obj != "object"){
		return (typeof obj === "number" ? obj : '"' + obj + '"');
	}
	var bool = Array.isArray(obj);
	res = bool ? "[" : "{";
	for(key in obj) {
		res += (!bool ? '"' + key + '" : ' : "") + ObjToString(obj[key]) + ", ";
	}
	return res.substr(0, res.length - 2) + (bool ? "]" : "}");
}
