import React, { Component } from 'react';
import './App.css';
const ReactHighcharts = require('react-highcharts');
const ReactDOM = require('react-dom');

//import { VictoryChart, VictoryZoomContainer,VictoryLine,VictoryBrushContainer,VictoryAxis } from 'victory';


const config = {
     chart: {
        type: 'spline'
    },
    title: {
        text: 'CPU Lifts'
    },
    subtitle: {
        text: 'Recorded lifts from 2016-2017'
    },
    xAxis: {
        type: 'datetime',
       /* dateTimeLabelFormats: { // don't display the dummy year
            month: '%e. %b',
            year: '%b'
        },*/
        title: {
            text: 'Date'
        }
    },
    yAxis: {
        title: {
            text: 'Weight (kg)'
        },
        min: 139
    },
    tooltip: {
        headerFormat: '<b>{series.name}</b><br>',
        pointFormat: '{point.x: %b,%e} <br> {point.y:.1f} kg'
    },

    plotOptions: {
        spline: {
            marker: {
                enabled: true
            }
        }
    },

    series: [{
        name: 'Squat',
        // Define the data points. All series have a dummy year
        // of 1970/71 in order to be compared on the same x axis. Note
        // that in JavaScript, months start at 0 for January, 1 for February etc.
        data: [
            [Date.UTC(2016, 11, 3), 200],
            [Date.UTC(2017, 1, 11), 215],
            [Date.UTC(2017, 4, 27), 250],
            [Date.UTC(2017, 9, 27), 272.5],
        ]
    }, {
        name: 'Bench',
        data: [
          [Date.UTC(2016, 11, 3), 137.5],
          [Date.UTC(2017, 1, 11), 145],
          [Date.UTC(2017, 4, 27), 155],
          [Date.UTC(2017, 9, 27), 162.5],
        ]
    }, {
        name: 'Deadlift',
        data: [
          [Date.UTC(2016, 11, 3), 210],
          [Date.UTC(2017, 1, 11), 235],
          [Date.UTC(2017, 4, 27), 240],
          [Date.UTC(2017, 9, 27), 260],
        ]
    }]

};


/*
const config = {
  
  chart: {
    type: 'column'
},

title: {
    text: 'Top Unequipped Totals in NB'
},

subtitle: {
    text: 'Subtitle'
},

legend: {
    align: 'right',
    verticalAlign: 'middle',
    layout: 'vertical'
},

xAxis: {
    categories: ['Squat', 'Bench', 'Deadlift', 'Total']
},

yAxis: {
    title: {
        text: 'kg'
    }
},

series: [{
    name: 'Mark Wasson',
    data: [252.5,170,302.5,725]
}, {
    name: 'RJ Forbes',
    data: [272.5,162.5,260,695]
}, {
    name: 'Guillaume Leblanc',
    data: [250,157.5,272.5,680]
}],

responsive: {
    rules: [{
        condition: {
            maxWidth: 500
        },
        chartOptions: {
            legend: {
                align: 'center',
                verticalAlign: 'bottom',
                layout: 'horizontal'
            }
        }
    }]

}
}
*/
class App extends Component {

  componentDidMount() {
       
        fetch('/records/lift/squat/unequipped/true/province/NB/weight/ALL/gender/M/limit/10')
        .then(res => res.json())
        .then(lifts => this.setState({ lifts }))
        .then();
        //let chart = this.refs.chart.getChart();
        //chart.series[0].addPoint({x: 10, y: 12});
    }

  constructor() {
    super();
    this.state = {
      lifts:[],
      chartConfig:{}
    };
     this.state.chartConfig = this.config;
  }

  handleZoom(domain) {
    this.setState({selectedDomain: domain});
  }

  handleBrush(domain) {
    this.setState({zoomDomain: domain});
  }

  render() {
    return (
      <div>
        <div>
       <center>
         <img  src="images/NBPL-Logo-Ship-Small.png" width="50%" height="50%" alt="NBPL"/>  
         </center>
        
        </div>
      </div>

    );
  }
}
/*
<ReactHighcharts config={config} />
<div>{this.state.lifts.map((item) => (<div>{item.name + ' ' + item.squat}</div>))}</div>
*/

// 
//  <ReactHighcharts config = {config}></ReactHighcharts>

export default App;



/*
 <VictoryChart width={350} height={300} scale={{x: "time"}}
          containerComponent={
            <VictoryZoomContainer
              zoomDimension="x"
              zoomDomain={this.state.zoomDomain}
              onZoomDomainChange={this.handleZoom.bind(this)}
            />
          }
        >
            <VictoryLine
              style={{
                data: {stroke: "tomato"}
              }}
              data={[
                {a: new Date(1982, 1, 1), b: 125},
                {a: new Date(1987, 1, 1), b: 257},
                {a: new Date(1993, 1, 1), b: 345},
                {a: new Date(1997, 1, 1), b: 515},
                {a: new Date(2001, 1, 1), b: 132},
                {a: new Date(2005, 1, 1), b: 305},
                {a: new Date(2011, 1, 1), b: 270},
                {a: new Date(2015, 1, 1), b: 470}
              ]}
              x="a"
              y="b"
            />

          </VictoryChart>
          <VictoryChart
            padding={{top: 0, left: 50, right: 50, bottom: 30}}
            width={550} height={100} scale={{x: "time"}}
            containerComponent={
              <VictoryBrushContainer
                brushDimension="x"
                brushDomain={this.state.selectedDomain}
                onBrushDomainChange={this.handleBrush.bind(this)}
              />
            }
          >
            <VictoryAxis
              tickFormat={(x) => new Date(x).getFullYear()}
            />
            <VictoryLine
              style={{
                data: {stroke: "tomato"}
              }}
              data={[
                {key: new Date(1982, 1, 1), b: 125},
                {key: new Date(1987, 1, 1), b: 257},
                {key: new Date(1993, 1, 1), b: 345},
                {key: new Date(1997, 1, 1), b: 515},
                {key: new Date(2001, 1, 1), b: 132},
                {key: new Date(2005, 1, 1), b: 305},
                {key: new Date(2011, 1, 1), b: 270},
                {key: new Date(2015, 1, 1), b: 470}
              ]}
              x="key"
              y="b"
            />
          </VictoryChart>*/