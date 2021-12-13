let margin = {
  top: 20,
  right: 50,
  bottom: 30,
  left: 100
}
let timeParser = d3.timeParse("%Y");

d3.csv("data/drug_abuse_cases_demographics_grouped.csv")
  .then(function(input) {
      const data = []
      for (var i = 0; i < input.length; i++) {
          data.push(input[i]);
      }
      data.forEach(function(d) {
          d.ADMYR = timeParser(d.ADMYR);
      });

      state_name = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia",
          "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
          "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
          "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
          "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
          "West Virginia", "Wisconsin", "Wyoming"
      ];

      var input;

      select = document.getElementById("selected_state");

      for (const val of state_name) {
          var option = document.createElement("option");
          option.value = val;
          option.text = val.charAt(0).toUpperCase() + val.slice(1);
          select.appendChild(option);
      }
      $('select').on('change', function(e) {

          d3.selectAll("circle").remove()
          d3.selectAll("text").remove()

          d3.select("g").remove();
          var svg = d3.select("svg")
          var g = svg.append("g").attr("transform", `translate(${margin.left}, ${margin.top})`).style("text-anchor", "end");

          var width = +svg.attr("width") - margin.left - margin.right;
          var height = +svg.attr("height") - margin.top - margin.bottom;

          var optionSelected = $("option:selected", this);
          input = this.value;
          state_rows = data.filter(function(item) {
              return item.STFIPS == input;
          });
          /**
           * LIST of ALL the substances and their corresponding legend location
           */
          var substancesInfo = [{
                  name: "Alcohol",
                  cx: width + 10,
                  cy: 40,
                  fill: "#f56e80"
              },
              {
                  name: "Methamphetamine",
                  cx: width + 10,
                  cy: 70,
                  fill: "rgb(22, 55, 143)"
              },
              {
                  name: "Heroin",
                  cx: width + 10,
                  cy: 100,
                  fill: "rgb(108, 247, 143)"
              },
              {
                  name: "Marijuana",
                  cx: width + 10,
                  cy: 130,
                  fill: "rgb(109, 23, 111)"
              },
              {
                  name: "Cocaine",
                  cx: width + 10,
                  cy: 160,
                  fill: "rgb(234, 155, 143)"
              }
          ]

          /**
           * ADDS Line plot to svg for each substance
           */
          for (var i = 0; i < substancesInfo.length; i++) {
              var substance = substancesInfo[i];
              svg.append("circle")
                  .attr("class", "legend")
                  .attr("cx", substance.cx)
                  .attr("cy", substance.cy)
                  .attr("r", 6)
                  .style("fill", substance.fill)

              svg.append("text").attr("x", substance.cx + 20)
                  .attr("y", substance.cy)
                  .text(substance.name)
                  .attr("class", "legend")
                  .style("font-size", "15px")
                  .attr("alignment-baseline", "middle")
                  .attr("font-family", "Georgia")
                  .style("fill", substance.fill)

          }
          /**
           * Sets X and Y scale
           */
          var dataXrange = d3.extent(state_rows, function(d) {
              return d.ADMYR;
          });
          var dataYrange = d3.extent(state_rows, function(d) {
              return d.Proportion_of_cases;
          });
          var mindate = dataXrange[0],
              maxdate = dataXrange[1];
          var minpropotion = dataYrange[0],
              maxpropotion = dataYrange[1];
          var xScale = d3.scaleTime().range([0, width]).domain(dataXrange);
          var yScale = d3.scaleLinear().range([height, 0]).domain([Math.min(0, minpropotion), Math.max(1, maxpropotion)]);

          g.append("g")
              .attr("transform", `translate(0, ${height})`)
              .call(d3.axisBottom(xScale).ticks(20));

          g.append("text")
              .attr("transform",
                  "translate(" + (width / 2) + " ," +
                  (height + margin.top + 10) + ")")
              .style("padding-bottom", "10px")

              .style("text-anchor", "middle")
              .text("Year");

          g.append("g")
              .call(d3.axisLeft(yScale).ticks(20))

          g.append("text")
              .attr("transform", "rotate(-90)")
              .attr("y", 0 - margin.left)
              .attr("x", 0 - (height / 2))
              .attr("dy", "1em")
              .style("text-anchor", "middle")
              .text("Population Propotion");

          for (var i = 0; i < substancesInfo.length; i++) {
              var state_rows_per_substance = state_rows.filter((_) => _.SUB1 == substancesInfo[i].name);
              var line = d3.line()
                  .x(d => xScale(d.ADMYR))
                  .y(d => yScale(d.Proportion_of_cases));
              g.append("path")
                  .datum(state_rows_per_substance)
                  .attr("class", substancesInfo[i].name)
                  .attr("fill", "none")
                  .attr("fill-opacity", 0)
                  .attr("stroke-opacity", 0)
                  .transition()
                  .duration(1000)
                  .attr("fill-opacity", 1)
                  .attr("stroke-opacity", 1)
                  .attr("d", line);
          }
      });

  })