<html>
  <head>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"></script>
	<script src='https://npmcdn.com/csv2geojson@latest/csv2geojson.js'></script>
	<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v1.5.0/mapbox-gl.js'></script>
	<script src='https://cdn.jsdelivr.net/npm/chart.js@2.9.3/dist/Chart.min.js'></script>
	<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v1.5.0/mapbox-gl.css' rel='stylesheet' />
	<title>Alfred Map</title>
	<style>
		#map {
		  position: absolute;
		  top: 0;
		  bottom: 0;
		  width: 100%;
		}
		body {
			margin: 0;
			padding: 0;
			font: 12px 'Helvetica Neue', Arial, Helvetica, sans-serif;
		}
		.h1 {
		  font-size: 1.25em;
		  font-weight: bold;
		  text-align: center;
		}
		.h2 {
		  font-size: 1.12em;
		  font-weight: bold;
		}
		.h3 {
		  margin: 10px;
		  font-size: 1.10em;
		}
		p {
		  font-size: 1.0em;
		  margin: 10px;
		  text-align: left;
		}
		ul {
		  margin-left: 20px;
		  padding: 0px;
		}
		ul li {
		  margin-left: 0px;
		  padding: 5px;
		}
		table {
			border-collapse: collapse;
		}
		td {
		 font-size:12px;
		 font-weight:normal;
		 border-style:none;
		 border-width:0px;
		 overflow:hidden;
		 word-break:normal;
		 text-align: right;
		}
		tr {
			padding: 0px;
			margin: 0px;
			border-style: none;
		}
		.bounding_box_topright {
		  top: 10px;
		  right: 50px;
		  position: absolute;
		  border-radius: 3px;
		  width: 275px;
		}	
			.info_panel {
				border-radius: 3px;
				background: rgba(255, 255, 255, 0.9);
				box-shadow:0 1px 2px rgba(0, 0, 0, 0.20);
				padding: 10px;
				line-height: 1.25em;
			}	
			.map-title {
				border-radius: 3px;
				background: rgba(255, 255, 0, 0.9);
				box-shadow:0 1px 2px rgba(0, 0, 0, 0.20);
				padding: 10px;
				line-height: 1.25em;
			}	
			.control_panel {
			  top: 10px;
			  position: relative;
				background: rgba(255, 255, 255, 0.9);
				box-shadow:0 1px 2px rgba(0, 0, 0, 0.20);
				border-radius: 3px;
				padding: 10px;
				line-height: 1.25em;
			}
		.deployment-plan {
		  top: 10px;
		  left: 10px;
		  position: absolute;
			background: rgba(255, 255, 255, 0.9);
			box-shadow:0 1px 2px rgba(0, 0, 0, 0.20);
			border-radius: 3px;
			padding: 10px;
			line-height: 1.25em;
		}
		.station_panel {
			position: absolute;
			height: 200px;
			width: 750px;
			display: none;
			top: 10px;
			left: 50%;
			margin: 0 0 0 -450px;
			background: rgba(255, 255, 255, 0.9);
			box-shadow:0 1px 2px rgba(0, 0, 0, 0.20);
			border-radius: 3px;
			padding: 10px;
			line-height: 1.25em;
		}
		.deploymentregionlegend {
		  bottom: 30px; 
		  right: 10px;
		  position: absolute;
		  background: rgba(255, 255, 255, 0.9);
		  overflow: auto;
		  border-radius: 3px;
		  padding: 10px;
		  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
		  line-height: 18px;
		}		
		.deploymentphaselegend {
		  bottom: 30px;
		  left: 10px;
		  position: absolute;
		  background: rgba(255, 255, 255, 0.9);
		  overflow: auto;
		  border-radius: 3px;
		  padding: 10px;
		  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
		  line-height: 18px;
		}		
		.legend-key {
		  display: inline-block;
		  border-radius: 20%;
		  width: 10px;
		  height: 10px;
		  margin-right: 5px;
		}
	</style>
    </head>
  <body>

	<div id='map'></div>
	
	<div class='deployment-plan'>
			<span class="h1">City Deployment Plan</span>
			<span id='MSA_details'><p>Hover over a city!</p></span>
	</div>
	
	<div class='station_panel' id='station_panel'>
			<span class="h1" id="charger_utilization_header"></span>
			<div class="chart-container" style="float: left; position: relative; height:175px; width:550px">
				<canvas id="utilization_graph"></canvas>
			</div>
			<div id="station_data" style="float: left; height:175px; width:200px">
			</div>
	</div>
	
	<div class='bounding_box_topright'>
		<div class='info_panel'>
				<div class='map-title'>
					<span class="h1">MP2 (Updated EVgo Plan)</span>
				</div>
				
				<div>
					<span class="h1"><br>General Info</span>
					<ul>
					<li>Small circles represent EVgo charger location. Color gradient based on utilization. Red (poor), Yellow (mid), Green (good)</li>
					<li>Click on the small circles to view charger utilization history</li>
					<li>Bubble color denotes deployment phase start. See legend at bottom left for details.</li>
					<li>Number in bubble is total build plan for that metro area.</li>
					</ul>
				</div>
		</div>
			
		<div class='control_panel'>
				<span class="h1">Control Panel</span>
				<hr>
				<div class='row' id='filters'>
					<span class="h2">Show deployments by:</span>
					<div class='row' id='chargers_sites'>
						<input id='radio_sites' type='radio' name='radio_chargers_sites' value='sites' checked='checked'>
						<label for='radio_sites'>Sites</label> (Chargers per site: <input type='text' id='chargerspersite' name='chargerspersite' style='width:2.5em' value=5>)
						<br>
						<input id='radio_chargers' type='radio' name='radio_chargers_sites' value='chargers'>
						<label for='radio_chargers'>Chargers</label>
					</div>
					<hr>
					<span class="h2">Show Tier:</span>
					<div class='row' id='tierfilters'>
						<input id='all' type='radio' name='radio_tier' value='all' checked='checked'>
						<label for='all'>All</label>
						<input id='tier1' type='radio' name='radio_tier' value=1>
						<label for='tier1'>Tier 1</label>
						<input id='tier2' type='radio' name='radio_tier' value=2>
						<label for='tier2'>Tier 2</label>
						<input id='tier3' type='radio' name='radio_tier' value=3>
						<label for='tier3'>Tier 3</label>
					</div>
					<hr>
					
					<div class='row' id='chargerfilters'>
						Show MSAs with <input type='text' id='minchargers' name='minchargers' style='width:2.5em' value=0> to <input type='text' id='maxchargers' name='maxchargers' style='width:2.5em' value=1000> chargers
					</div>
					
					<hr>
					
					<div class='row' id='hide_evgo'>
						EVgo Stations: <input id='showevgo' type='radio' name='radio_evgo' value='show' checked='checked'>
						<label for='showevgo'>Show</label>
						<input id='hideevgo' type='radio' name='radio_evgo' value="hide">
						<label for='hideevgo'>Hide</label>
					</div>
				</div>
		</div>
	</div>
	
	<div class='deploymentregionlegend' id='deploymentregionlegend'>
		<span class="h2">EPC Deployment Regions</span>
	</div>
	
	<div class='deploymentphaselegend' id='deploymentphaselegend'>
		<span class="h2">Deployment Phase</span>
	</div>
	
	<script>

		mapboxgl.accessToken = 'pk.eyJ1IjoiYm9ic2FjYW1hbm8xMjM0IiwiYSI6ImNqazQ1azEwajBhejAzdnBqZnVtbmM1aDIifQ.eXFUYiQS94mz3sCoZaGxLg';
		
		var map = new mapboxgl.Map({
			container: 'map', // container id
			//style: 'mapbox://styles/bobsacamano1234/ck3bwgqwr2hcx1cnp53nxa7nq', //Streets style
			 style: 'mapbox://styles/bobsacamano1234/ck3bwvg6b2hkb1cloc8sis8li', //Basic style
			center: [-96.713, 40.424],
			zoom: 4
		});

		// Load deployment plan data
		var deploymentplan = "";		
		$(document).ready(function() {
			$.ajax({
				type: "GET",
				url: 'mp2.csv',
				dataType: "text",
				success: function(csvData) {
					csv2geojson.csv2geojson(csvData, {
						latfield: "Latitude",
						lonfield: "Longitude",
						delimiter: ",",
						numericFields: "ATK Ranking,Tier,Population,ZEV,2021 DEMAND,2022 DEMAND,2023 DEMAND,2024 DEMAND,2025 DEMAND,2026 DEMAND,2027 DEMAND,2028 DEMAND,2029 DEMAND,Phase 1 BUILD,Phase 2 BUILD,Phase 3 BUILD,Phase 4 BUILD,Phase 5 BUILD,Sum Chargers,Phase Start"
					}, function(err, data) {
						deploymentplan = data;
					});				
				}
			 });
		});
		
		// Load EVgo charger data
		var evgochargers = "";		
		$.ajax({
				type: "GET",
				url: 'evgo_data.csv',
				dataType: "text",
				success: function(evgo) {
					csv2geojson.csv2geojson(evgo, {
						latfield: "Latitude",
						lonfield: "Longitude",
						delimiter: ",",
						numericFields: "Nov-17,Dec-17,Jan-18,Feb-18,Mar-18,Apr-18,May-18,Jun-18,Jul-18,Aug-18,Sep-18,Oct-18,Nov-18,Dec-18,Jan-19,Feb-19,Mar-19,Apr-19,May-19,Jun-19,Jul-19,Aug-19,Sep-19"
					}, function(err, data) {
						evgochargers = data;
					});
				}
		});

		map.on('load', function () {		
			// Show zoom/centering controls on top right of map
			map.addControl(new mapboxgl.NavigationControl());
			
			// ---------------------- MASTERPLAN DEPLOYMENT SECTION ----------------------
			
			// Load deployment plan source data
			map.addSource("deploymentplan", {
				"type": "geojson",
				"data": deploymentplan,
				// ensure that all features have unique  IDs
				'generateId': true
			});
			
			// Add layer for EPC deployment regions		
			map.addLayer({
				"id": "epcregions",
				"type": "fill",
				"source": { type: 'geojson', data: "epcregions.geojson"},
				"paint": {
					"fill-color": [
						  "match",
						  ["get", "region"],
						  ["Southern California"],"#8dd3c7",
						  ["Northern California"],"#ffffb3",
						  ["Pacific Northwest"],"#bebada",
						  ["Mountain"],"#fb8072",
						  ["Desert Southwest"],"#80b1d3",
						  ["South Central"],"#fdb462",
						  ["Central"],"#b3de69",
						  ["Northeast"],"#a65628",
						  ["Mid-Atlantic"],"#f781bf",
						  ["Southeast"],"#999999",
						  ["Florida"],"#8043c7",
						  "#000000"
						]
				}
			// Sets this layer to be immediately below 'national_park' in the layer stack.
			}, 'national-park');
			
			// Crate EPC deployment region legend
			var regions = ['Southern California', 	'Northern California', 	'Pacific Northwest', 	'Mountain', 	'Desert Southwest', 'South Central','Central', 	'Northeast','Mid-Atlantic',	'Southeast', 	'Florida'];
			var regioncolors = ['#8dd3c7',				'#ffffb3',				'#bebada',				'#fb8072',		'#ff7f00',			'#fdb462',		'#b3de69',	'#a65628',	'#f781bf', 		'#999999',		'#8043c7'];

			for (i = 0; i < regions.length; i++) {
			  var region = regions[i];
			  var regioncolor = regioncolors[i];
			  var item = document.createElement('div');
			  var key = document.createElement('span');
			  key.className = 'legend-key';
			  key.style.backgroundColor = regioncolor;

			  var value = document.createElement('span');
			  value.innerHTML = region;
			  item.appendChild(key);
			  item.appendChild(value);
			  deploymentregionlegend.appendChild(item);
			}
						
			// Add layers for Masterplan deployment (bubbles and labels)
			map.addLayer({
				"id": "masterplanCircles",
				"type": "circle",
				"source": "deploymentplan",
				"paint": {
					"circle-opacity": 0.6,							
					"circle-stroke-color": "#ffffff",
					"circle-stroke-width": 1,
					"circle-stroke-opacity": 1,
					"circle-radius": [
						// Up to 50, radius = 12, after 50 = make the radius of the circle the square root of the number of chargers * 2.2
						"step",
						["get", "Sum Chargers"],
						12,
						50, ["*", ["sqrt", ["get", "Sum Chargers"]], 1.5,],
						
					],
					"circle-color": [
						"match",
						["get", "Phase Start"],
						[1], "#3a9e00",
						[2],  "#4524ff",
						"#ff2424"
					]
				}
			});
			map.addLayer({
				"id": "masterplanLabels",
				"type": "symbol",
				"source": "deploymentplan",
				"layout": {
					"text-field": [
					  "to-string",
					  ["round", ["/", ["get", "Sum Chargers"], parseInt(document.getElementById('chargerspersite').value, 10)]]
					],
					"text-size": 12,
					"text-line-height": 1.2,
					"text-font": ["Open Sans Bold","Arial Unicode MS Regular"],
					"text-allow-overlap": true,
					"text-ignore-placement": true
				},
				
				"paint": {
					"text-halo-color": "#ffffff",
					"text-halo-width": 1,
				}
			});
			
			// Create legend for deployment phases
			var phases = ['Phase 1 (2020 Start)', 	'Phase 2 (2021 Start)', 	'Phase 3 (2022 Start)'];
			var phasecolors = ['#3a9e00',	'#4524ff',	'#ff2424'];
			
			for (i = 0; i < phases.length; i++) {
			  var phase = phases[i];
			  var phasecolor = phasecolors[i];
			  var item = document.createElement('div');
			  var key = document.createElement('span');
			  key.className = 'legend-key';
			  key.style.backgroundColor = phasecolor;

			  var value = document.createElement('span');
			  value.innerHTML = phase;
			  item.appendChild(key);
			  item.appendChild(value);
			  deploymentphaselegend.appendChild(item);
			}
			
			// Deployment data mouseover actions
			map.on('mousemove', function(e) {
			  var masterplan = map.queryRenderedFeatures(e.point, {layers: ['masterplanCircles']});
			  if (masterplan.length > 0) {
				document.getElementById('MSA_details').innerHTML = '<p><b>Name:</b> ' + masterplan[0].properties.MSA
				+ '<br><b>Population:</b> ' + numberwithcommas(masterplan[0].properties.Population) + '</p>'
				+ '<p><b>Deployment Tier</b>: ' + masterplan[0].properties.Tier + '</p>'
				+ '<p><b>Phase 1:</b> ' + numberwithcommas(Math.round(masterplan[0].properties['Phase 1 BUILD'])) + ' chargers<br>'
				+ '<b>Phase 2:</b> ' + numberwithcommas(Math.round(masterplan[0].properties['Phase 2 BUILD'])) + ' chargers<br>'
				+ '<b>Phase 3:</b> ' + numberwithcommas(Math.round(masterplan[0].properties['Phase 3 BUILD'])) + ' chargers<br>'
				+ '<b>Phase 4:</b> ' + numberwithcommas(Math.round(masterplan[0].properties['Phase 4 BUILD'])) + ' chargers<br>'
				+ '<b>Phase 5:</b> ' + numberwithcommas(Math.round(masterplan[0].properties['Phase 5 BUILD'])) + ' chargers</p>'
				;
				
			  } else {
				document.getElementById('MSA_details').innerHTML = '<p>Hover over a city!</p>';
			  }
			});
			
			// ---------------------- CHARGER SECTION ----------------------
			// Load EVgo charger source data
			map.addSource("evgochargers", {
				"type": "geojson",
				"data": evgochargers,
				// ensure that all features have unique  IDs
				'generateId': true
			});
			
			// Add EVgo charger data onto map
			map.addLayer({
				"id": "evgoChargers",
				"type": "circle",
				"source": 'evgochargers',
				"paint": {
					"circle-opacity": 0.9,							
					"circle-stroke-color": "#4f4f4f",
					"circle-stroke-width": 1,
					"circle-stroke-opacity": 0.7,
					"circle-color": [
								'case', ['boolean', ['feature-state', 'clicked'], false],
						'#000', 
						[ "interpolate", ["linear"],
						["get", "Sep-19"],
						0,"#ff0000",
						12,"#fbf83c",
						22, "#20fb18"
						]
					]
				}
			}, 'masterplanCircles');
			
			// OnClick actions for EVgo charger data
			var clickedCharger = null;
			var utilization_graph;
			
			map.on('click', 'evgoChargers', function(e) {
				// load into a variable the charger data that was clicked
				var evgo_data = map.queryRenderedFeatures(e.point, {layers: ['evgoChargers']});
				
				// If there is a previously clicked charger circle, return it to the default paint mode (render it unclicked)
				if (clickedCharger) { map.removeFeatureState({source: 'evgochargers', id: clickedCharger,}); }
				
				// Paint currently clicked charger circle
				clickedCharger = e.features[0].id;
				map.setFeatureState({source: 'evgochargers', id: e.features[0].id,}, {clicked: true});

				// Load labels for utilization graph (TODO: somehow make this load dynamically from data source)
				var labels = ['Nov-17','Dec-17','Jan-18','Feb-18','Mar-18','Apr-18','May-18','Jun-18','Jul-18','Aug-18','Sep-18','Oct-18','Nov-18','Dec-18','Jan-19','Feb-19','Mar-19','Apr-19','May-19','Jun-19','Jul-19','Aug-19','Sep-19'];
				
				// instantiate array that will hold the data for the utilization graph
				var utilization_graph_data = [];
				
				// Iterate through the labels array, pull the data point for the clicked charger that corresponds with the label array item (date), and load that datapoint into the utilization graph data array.
				labels.forEach(myFunction);				
				function myFunction(item, index) {
					utilization_graph_data.push(evgo_data[0].properties[item]);
				};
				
				// Define the charger utilization graph data and formatting here. (via JSON array)
				var utilization_graph_config = {
					type: 'line',
					data: {
						labels: labels,
						datasets: [{
							data: utilization_graph_data,
							backgroundColor: [
								'rgba(255, 99, 132, 0.2)',
							],
							borderColor: [
								'rgba(255, 99, 132, 1)',
							],
							borderWidth: 1
						}]
					},
					options: {
						maintainAspectRatio:false,
						respnsive:true,
						scales: {
							yAxes: [{
								ticks: {
									beginAtZero: true,
									 callback: function(value, index, values) {
										return (value).toFixed(2) + "%"
									}
								}
							}]
						},
						legend: {
							display: false,
						},
						tooltips: {
							enabled: true,
						}
					}
				};
				
				// Show station panel at top of window
				document.getElementById('station_panel').style.display = 'block';
				
				
				var makeGMRed = "";
				if (evgo_data[0].properties['Direct Margin']<0) { makeGMRed='style="color: red;"';};
				
				var makeNOMRed = "";
				if (evgo_data[0].properties['Network Operating Margin']<0) { makeNOMRed='style="color: red;"';};
							
				// Update utilization graph header
				document.getElementById('charger_utilization_header').innerHTML = 'Station: ' + evgo_data[0].properties['Property Name'] + ' (' + evgo_data[0].properties['Capacity'] + ' kW)<hr>';
				document.getElementById('station_data').innerHTML = '<table style="width: 100%;"><tr><td><b>Charger ID: </b></td><td><b>' + evgo_data[0].properties['Charger ID'] + '</b></td></tr> <tr><td></td><td></td></tr>' + 
					'<tr><td>Sessions per Day to B/E:</td><td>	 			' + formatDecimal.format(evgo_data[0].properties['Sessions to BE']) + '</td></tr>' + 
					'<tr style="height:10px;"><td></td><td></td></tr>' + 
					'<tr><td>Revenue:</td><td>	 			' + formatCur.format(evgo_data[0].properties['Revenue']) + '</td></tr>' + 
					'<tr><td>Variable Expense:</td><td> 	' + formatCur.format(evgo_data[0].properties['Variable Expense']*-1) + '</td></tr>' + 
					'<tr style="background-color: #f0f0f0;"><td><b>Gross Margin:</b></td><td  ' + makeGMRed + '><b> 	' + formatCur.format(evgo_data[0].properties['Direct Margin']) + '</b></td></tr>' + 
					'<tr><td>Fixed Expense:</td><td>	 	' + formatCur.format(evgo_data[0].properties['Fixed Expense']*-1) + '</td></tr>' + 
					'<tr style="background-color: #f0f0f0;"><td><b>Operating Margin:</b></td><td ' + makeNOMRed + '><b> 	' + formatCur.format(evgo_data[0].properties['Network Operating Margin']) + '</b></td></tr></table>' + 
					'<br><span width="100%" style="display:block; font-size:11px; text-align:right;"><i>*Profitability data from 2Q2019</i></span>' 
					;

				      if (utilization_graph) {
						utilization_graph.destroy();
					  }

				// Set defaults for the charger utilization chart
				Chart.defaults.global.elements.point.borderColor = 'rgba(255, 99, 132, 1)';
				Chart.defaults.global.elements.point.backgroundColor = 'rgba(255, 99, 132, 1)';
				
				// Instantiate the charger utilization graph using the config which defines format and data
				var ctx = document.getElementById('utilization_graph').getContext('2d');
				utilization_graph = new Chart(ctx, utilization_graph_config);				


			});

			// Change mouse pointer when mouse is hovered over a charger circle
			map.on('mouseenter', 'evgoChargers', function(e) {
				map.getCanvas().style.cursor = 'pointer';
			});

			map.on('mouseleave', 'evgoChargers', function() {
				map.getCanvas().style.cursor = '';
			});


			// ---------------------- CONTROL PANEL ----------------------
			// Load filters when settings are changed in control center
			document.getElementById('filters').addEventListener('change', function(e) {
		  
				var minchargers = parseInt(document.getElementById('minchargers').value, 10);
				var maxchargers = parseInt(document.getElementById('maxchargers').value, 10);				
				var selectedtier = parseInt(document.querySelector('input[name = "radio_tier"]:checked').value,10);
				var chargerspersite =  parseInt(document.getElementById('chargerspersite').value, 10);

				if (document.querySelector('input[name = "radio_chargers_sites"]:checked').value === 'sites') {
					map.setLayoutProperty('masterplanLabels', 'text-field', ["to-string", ["round", ["/", ["get", "Sum Chargers"], parseInt(chargerspersite, 10)]]]);
				} else {
					map.setLayoutProperty('masterplanLabels', 'text-field', ["to-string", ["round", ["get", "Sum Chargers"]]]);
				}

				if (document.querySelector('input[name = "radio_tier"]:checked').value !== 'all') {
					map.setFilter('masterplanCircles', ['all', ['>=', 'Sum Chargers', minchargers], ['<=', 'Sum Chargers', maxchargers], ['==', 'Tier', selectedtier]]);
					map.setFilter('masterplanLabels', ['all', ['>=', 'Sum Chargers', minchargers], ['<=', 'Sum Chargers', maxchargers], ['==', 'Tier', selectedtier]]);			
				} else {
					map.setFilter('masterplanCircles', ['all', ['>=', 'Sum Chargers', minchargers], ['<=', 'Sum Chargers', maxchargers]]);
					map.setFilter('masterplanLabels', ['all', ['>=', 'Sum Chargers', minchargers], ['<=', 'Sum Chargers', maxchargers]]);
				}
				
				if (document.querySelector('input[name = "radio_evgo"]:checked').value === 'show') {
					map.setLayoutProperty('evgoChargers', 'visibility', 'visible');
				} else {
					map.setLayoutProperty('evgoChargers', 'visibility', 'none');
				}
			});

		});
		
		function numberwithcommas(x) {
			return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		};
		
		const formatCur = new Intl.NumberFormat('en-US', {
		  style: 'currency',
		  currency: 'USD',
		  minimumFractionDigits: 2
		})
		
		const formatDecimal = new Intl.NumberFormat('en-US', {
		  style: 'decimal',
		  minimumFractionDigits: 2,
		  maximumFractionDigits: 2,
		})
	</script>
  </body>
</html>

