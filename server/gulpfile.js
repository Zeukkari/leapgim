var gulp = require('gulp')
, gutil = require('gulp-util')
, coffee = require('gulp-coffee')
, pm2 = require('pm2')
, sourcemaps = require('gulp-sourcemaps');

gulp.task('compile-coffee', function () {
    gulp.src('./src/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({ bare: true })).on('error', gutil.log)
    .pipe(sourcemaps.write("./maps"))
    .pipe(gulp.dest('./lib'));
});
gulp.task('reload', function() {
  pm2.connect(true, function() {
    pm2.restart('leapgim-server', function() {
      console.log('leapgim-server restarted');
      pm2.disconnect(function() { process.exit(0) });
    });
  });
});

gulp.task('watch', function () {
    gulp.watch(['./src/*.coffee'], ['compile-coffee']);
});
