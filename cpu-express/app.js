var config = require('./config');
var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');

var index = require('./routes/index');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', index);

var massive = require("massive");

var massiveInstance = massive.connectSync({connectionString : config.connectionString}) 
app.set('db', massiveInstance);

var db = app.get('db');

app.get('/records/lift/:lift/unequipped/:unequipped/province/:province/weight/:weight/gender/:gender/limit/:limit', function(req, res, next) {
  console.log("getting records");
  var lift = req.params.lift;
  var unequipped = req.params.unequipped;
  var province = req.params.province;
  var weight = req.params.class;
  var gender = req.params.gender;
  var limit = req.params.limit;
  var sqlQuery = "";
  if(lift == "all"){
    sqlQuery = "SELECT * FROM liftdb WHERE unequipped = " + unequipped + "  AND total IS NOT NULL AND province = '" + province + "' AND gender = '" + gender + "' ORDER BY total DESC LIMIT "+limit+";";
   }else {
    sqlQuery = "SELECT * FROM liftdb WHERE unequipped = " + unequipped + "  AND " + lift + " IS NOT NULL AND province = '" + province + "' AND gender = '" + gender + "' ORDER BY " + lift + " DESC LIMIT "+limit+";";
   };


  console.log("SQL Query: " + sqlQuery);
  db.run(sqlQuery, function(err, json ){
       res.json(json);
  });
});



// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});



module.exports = app;
