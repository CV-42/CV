// This is the main function, to create the message.
// The setup for the Google server is hidden in Code.gs though.

function textBody() {

  // weather data is contained in the following HTML-code
  let spotwx = UrlFetchApp.fetch('https://spotwx.com/products/grib_index.php?model=gfs_pgrb2_0p25_f&lat=-49.28841&lon=-73.1535&tz=America/Argentina/Rio_Gallegos&display=table');
  let spotwxStr = spotwx.getContentText(); // contains two lines such as:    
  //      var aDataSet = [
  //      ['2023/11/13 03:00','2023/11/13','03:00','-3.4','93','24','297','39','0.0','100','996.4','','0.0','0.0','0.0','0.0','20','294','-1.3','20','294','10.2','1084','-4.4','','','',''],['2023/11/13 04:00','2023/11/13','04:00','-3.6','93','23','301','51','0.9','100','995.6','SN','0.0','0.9','0.0','0.0','19','299','-1.3','19','299','9.0','1045','-4.4','0','0','287','296'] (... and so on ...)    ];

  // remove unneccessary lines, js-code-snippets, spaces, tabs, breaks, Anführungzeichen:
  let startIdx = spotwxStr.indexOf("var aDataSet = ");
  let endIdx = spotwxStr.lastIndexOf("$(document).ready(function()");
  let dataStr = spotwxStr.slice(startIdx+15, endIdx).replace(/ /g, "").replace(/\t/g, "").replace(/(\r\n|\n|\r)/gm, "").replace(/'/g, "");

  // each entry is array (of strings) for one time point:
  let dataArr = (dataStr.replace("[[", "").replace("]]", "").split("],[")).map(str => str.split(","));
  // an example entry: [2023/11/1303:00,2023/11/13,03:00,-3.4,93,24,297,39,0.0,100,996.4,,0.0,0.0,0.0,0.0,20,294,-1.3,20,294,10.2,1084,-4.4,,,,]

  // grabbing the altitude wind speed from other page (it would be better to get all data from that side...):
  var asStr = (UrlFetchApp.fetch('https://spotwx.com/products/grib_index.php?model=gfs_pgrb2_0p25_f&lat=-49.28841&lon=-73.1535&tz=America/Argentina/Rio_Gallegos&display=graph')).getContentText();
  let asStartIdx = asStr.indexOf("700mb Wind");
  asStr = asStr.slice(asStartIdx, asStr.length).replace(/ /g, "").replace(/\t/g, "").replace(/(\r\n|\n|\r)/gm, "").replace(/'/g, "");
  let asEndIdx = asStr.indexOf("index");
  asStr = asStr.slice(0, asEndIdx);
  let asArr = asStr.match(/(?<=y:)[\d.]*(?=,)/g);   // grab the numbers between "y:" and the following ",".

  // attach altitude wind speeds to dataArr
  for (let i = 0; i < dataArr.length; i++){
    dataArr[i].push(asArr[i]);
  }

  // save model_date : "DDHH"
  let modelDateTime = dataArr[0][0].slice(8,10) + dataArr[0][0].slice(10,12);  // dataArr[0][0] is for example = "2023/11/1309:00"

  // search index of current time in dataArr:
  let dates = dataArr.map(timeArray => timeArray[1].slice(8,10));
  let hours = dataArr.map(timeArray => parseInt(timeArray[2].slice(0,2)));
  let nowArgentiniaStr = new Date().toLocaleString("en-US", { timeZone: "America/Argentina/Buenos_Aires" });
  let nowArgentinia = new Date(nowArgentiniaStr);
  let hoursArgentinia = nowArgentinia.getHours();
  let dateArgentinia = nowArgentinia.getDate();
  var nowIdx = -1;
  for (let i = 0; i < hours.length; i++){
    if ((parseInt(dates[i]) == dateArgentinia) && (parseInt(hours[i]) == hoursArgentinia)) {
      nowIdx = i;
      break;
    }
  }

  // select information fields:

  // time (hours on the clock in Argentinia):
  var fields = [2]; var names = ["h"]; var format = [x => x.slice(0,2)];
  // temperature in Celsius:
  fields.push(3); names.push("T");     format.push(x => Math.round(parseFloat(x)).toString());

  // wind speed in km/h
  fields.push(5); names.push("s");     format.push(x => x);

  // altitude wind speed (700mb wind)
  fields.push(dataArr[0].length - 1); names.push("A");    format.push(x => x);

  // wind direction divided by 10 and rounded
  fields.push(6); names.push("d");  format.push(x => Math.round(parseFloat(x)/10));

  // wind gusts
  //fields.push(7); names.push("g");     format.push(x => x);

  // accumulated precipitation rounded
  fields.push(8); names.push("N");    format.push(x => Math.round(parseFloat(x)).toString());

  // humidity in % (if 100% --> "F" in order to save signs and to have even formatting of chart):
  //fields.push(4); names.push("hu");    format.push(x => {
  //  if (x == "100"){
  //    return "F";
  //  } else {
  //    return x;
  //  }
  //});

  // cloud cover in % (if "100" then convert to "F" to save signs and maintain order in table)
  fields.push(9); names.push("c");      format.push(x => {
    if (x == "100"){
      return "F";
    } else {
      return x;
    }
  });

  // last two digits of rounded sea level pressure 
  //fields.push(10);names.push("p");    format.push(x => (Math.round(parseFloat(x)) % 100).toString());

  // put all selected fields into new array and apply predefined formatting:
  var dataSel = dataArr.map(timeArray => fields.map(idx => timeArray[idx]));
  for (let i = 0; i < dataSel.length; i++){
    for (let j = 0; j < dataSel[i].length; j++){
      dataSel[i][j] = format[j](dataSel[i][j]);
    };
  };

  // select interesting time points:
  let predictHours = [2,4,6,9,12,15,18,21,24,30,36,42,54];
  let timeIds = predictHours.map(h => h + nowIdx);
  dataSel = timeIds.map(i => dataSel[i]);


  let output = modelDateTime.toString()
    + "\n"
    + names.join("")
    + "\n"
    + dataSel.map(entryArray => entryArray.join(",")).join("\n");

  Logger.log(output);
  return output;
}