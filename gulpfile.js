var gulp = require("gulp"),
    watch = require("gulp-watch"),
    livescript = require("gulp-livescript");


/*
 * Purely for developemnt
 * Watch files for changes then build.
 */
gulp.task("default", function () {
  watch('lib/ly/stash.ly', function () {
    return gulp.src('lib/ly/stash.ly').
      pipe(livescript({bare: true})).
      pipe(gulp.dest("dist/"));
  });
});
