/**
 * TOOLTIP DATA
 */
function tooltipHtml(n, d) {
    return "<h4>" + n + "</h4><table>" +
        "<tr><td>Total Population</td><td>" + (d.population) + "</td></tr>" +
        "<tr><td>Total Cases</td><td>" + (d.cases) + "</td></tr>" +
        "</table>";
}

d3.csv("data/state_population_infographics.csv")
    .then(function(input) {
        data = []
        for (var i = 0; i < input.length; i++) {
            data.push(input[i]);
        }
        var tooltipData = {};
        let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware",
            "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
            "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
            "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
            "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
            "West Virginia", "Wisconsin", "Wyoming"
        ]
        states.forEach(function(d) {

            state_row = data.filter(function(item) {
                return item.STFIPS == d;
            });

            if (state_row != null && state_row.length > 0) {
                var total_cases = state_row[0].Total_cases,
                    total_population = state_row[0].Total_population
                tooltipData[d] = {
                    cases: total_cases,
                    population: total_population
                };
            }
        });
        uStates.draw("#statesvg", tooltipData, tooltipHtml);
        d3.select(self.frameElement).style("height", "600px");

    });