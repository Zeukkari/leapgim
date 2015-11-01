var coffee = require('gulp-coffee')
, gulp = require('gulp')
, gutil = require('gulp-util')
, sourcemaps = require('gulp-sourcemaps');

gulp.task('compile-coffee', function () {
    gulp.src('./src/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee({ bare: true })).on('error', gutil.log)
    .pipe(sourcemaps.write("./maps"))
    .pipe(gulp.dest('./lib'));
});

gulp.task('watch', function () {
    gulp.watch(['./src/*.coffee'], ['compile-coffee']);
});
