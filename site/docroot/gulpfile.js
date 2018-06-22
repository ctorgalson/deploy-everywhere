'use strict';

const autoprefixer = require('autoprefixer');
const gulp = require('gulp');
const postcss = require('gulp-postcss');
const sass = require('gulp-sass');
const sourcemaps = require('gulp-sourcemaps');
const sassSrc = './src/sass/**/*.scss';
const cssDest = './css'

gulp.task('sass', () => gulp.src(sassSrc)
  .pipe(sourcemaps.init())
  .pipe(sass({outputStyle: 'compressed'})).on('error', sass.logError)
  .pipe(postcss([autoprefixer()]))
  .pipe(sourcemaps.write('.'))
  .pipe(gulp.dest(cssDest))
);

gulp.task('watch', () => gulp.watch(sassSrc, ['sass']));

gulp.task('build', ['sass']);
