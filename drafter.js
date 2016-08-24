var fs = require('fs');
var glob = require('glob');

var _ = require('lodash');
var protagonist = require('protagonist');

var metamorphoses = require('./lib/metamorphoses.js');
var blueprintAdapter = metamorphoses.apiBlueprintAdapter;
var refractAdapter = metamorphoses.refractAdapter;
var lodash = require('./lib/adapters/refract/helper.js')

var filenames = glob.sync('../drafter/test/fixtures/*/*.apib');

var success = 0;
var failures = 0;
var parseError = 0;
var failureResult = [];
var totalASTAdapterDuration = 0;
var totalRefractAdapterDuration = 0;

/*
 * Convert a duration from `process.hrtime()` into milliseconds.
 */
function ms(duration) {
  return duration[0] * 1000 + duration[1] / 1e6;
}

_.forEach(filenames, function(filename) {
  var blueprint = fs.readFileSync(filename, 'utf-8');

  try {
    var parseResultAST = protagonist.parseSync(blueprint, {type: 'ast'});
    var parseResultElement = protagonist.parseSync(blueprint);
  } catch (exception) {
    parseError += 1;
    return;
  }

  // API Blueprint AST
  var startAST = process.hrtime();
  var astAST = blueprintAdapter.transformAst(parseResultAST.ast);
  totalASTAdapterDuration = ms(process.hrtime(startAST));

  // Refract AST
  var apiElement = lodash.chain(parseResultElement)
    .content()
    .find({element: 'category', meta: {classes: ['api']}})
    .value();

  var startRefract = process.hrtime();
  var refractAST = refractAdapter.transformAst(apiElement);
  totalRefractAdapterDuration += ms(process.hrtime(startRefract));

  //if (_.eq(refractAST, astAST)) {
  if (JSON.stringify(refractAST) === JSON.stringify(astAST)) {
    process.stdout.write('.');
    success += 1;
  } else {
    process.stdout.write('F');
    failures += 1;

    failureResult.push({
      filename: filename,
      refract: refractAST,
      ast: astAST,
    });
  }
});

process.stdout.write('\n\n');

_.forEach(failureResult, function(failure) {
  console.log(failure.filename);

  fs.writeFileSync(failure.filename + '.ast.json', JSON.stringify(failure.ast, null, 2));
  fs.writeFileSync(failure.filename + '.refract.json', JSON.stringify(failure.refract, null, 2));
});

process.stdout.write('\n\n');

console.log('Success: ' + success);
console.log('Failures: ' + failures);
console.log('Parse Errors: ' + parseError);
console.log('Average Refract Adapter Speed: ' + (totalRefractAdapterDuration / totalASTAdapterDuration).toFixed(1) + ' times slower than AST Adapter');

if (failures > 0) {
  process.exit(1);
}
