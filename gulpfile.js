var gulp = require("gulp"),
    watch = require("gulp-watch"),
    plumber = require("gulp-plumber"),
    livereload = require("gulp-livereload"),
    livescript = require("gulp-livescript");


/*
 * Purely for developemnt
 * Watch files for changes then build.
 */
gulp.task("default", function () {
  livereload.listen();
  watch('lib/ls/*.ls', function () {
    console.log("reload");
    return gulp.src('lib/ls/maptiler.ls').
      pipe(plumber()).
      pipe(livescript({bare: true})).
      pipe(gulp.dest("dist/")).
      pipe(livereload());
  });
});

gulp.task("deploy", function () {
  return gulp.src('lib/ls/maptiler.ls').
    pipe(livescript({bare: true})).
    pipe(gulp.dest("./"));
});
