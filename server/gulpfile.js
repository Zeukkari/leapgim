// including plugins
var gulp = require('gulp')
, coffee = require("gulp-coffee")
, livereload = require('gulp-livereload')
, exec = require('child_process').exec
, connect = require('gulp-connect-pm2')
, sourcemaps = require('gulp-sourcemaps');

// Task: Coffeescript compile
gulp.task('compile-coffee', function () {
    gulp.src('./src/*.coffee') // path to your file
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('./lib'));
});
gulp.task('live-reload', function () {
    gulp.src('./src/*.coffee') // path to your file
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('./lib'))
    .pipe(livereload());
});
// Task: Coffeescript lint
gulp.task('coffeeLint', function () {
    gulp.src('./CoffeeScript/*.coffee') // path to your files
    .pipe(coffeelint())
    .pipe(coffeelint.reporter());
});
// Task: Watch
gulp.task('watch-coffeescript', function () {
    gulp.watch(['./src/*.coffee'], ['compile-coffee']);
});
gulp.task('live-server', function () {
    gulp.watch(['./src/*.coffee'], ['live-reload']);
});
gulp.task('connect', function() {
  connect.server();
});

// plugins.livereload.listen();
//     gulp.watch('src/*.coffee', ['coffee-compile']);
//     gulp.watch('assets/js/*.js', ['build-js']);
//     gulp.watch('assets/less/**/*.less', ['build-css']);
