var gulp = require('gulp');
var sass = require('gulp-sass');

gulp.task('sass', function() {
  return gulp.src('./src/sass/**/*.scss')
    .pipe(sass({
      outputStyle: "compressed"
    }).on('error', sass.logError))
    .pipe(gulp.dest('./css'));
});

gulp.task('watch', function() {
  gulp.watch('./src/sass/**/*.scss', ['sass']);
});

gulp.task('build', ['sass']);
