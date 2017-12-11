/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');
const drafter = require('drafter');

const metamorphoses = require('../src/metamorphoses');


const source = `\
FORMAT: 1A

# Test API
## Test [/test]
### Test Test Test [GET]

+ Request
+ Response 200 (application/json)
    + Body

            {"message": "Hello World!"}

+ Request User Error
+ Response 400 (application/json)
    + Body

            {"error": "This is error :("}

+ Request Something Not Found
+ Response 404 (application/json)
    + Body

            {"error": "This is error :("}\
`;


const isApiElement = function(element) {
  if (element.element !== 'category') { return false; }
  return (element.meta != null ? element.meta.classes.indexOf('api') : undefined) !== -1;
};


describe('Multiple Transactions', () =>
  describe('when API Blueprint has three request-response pairs', function() {
    let applicationAst = undefined;

    beforeEach(function(done) {
      const mediaType = 'application/vnd.refract.api-description+json';
      const adapter = metamorphoses.createAdapter(mediaType);

      return drafter.parse(source, function(err, parseResult) {
        if (err) { return done(err); }

        const apiElement = parseResult.content.filter(isApiElement)[0];
        applicationAst = adapter.transformAst(apiElement);
        return done();
      });
    });

    it('produces three requests', () => assert.equal(applicationAst.sections[0].resources[0].requests.length, 3));
    it('produces three responses', () => assert.equal(applicationAst.sections[0].resources[0].responses.length, 3));

    const examples = [
      {reqName: '', resStatusCode: 200},
      {reqName: 'User Error', resStatusCode: 400},
      {reqName: 'Something Not Found', resStatusCode: 404}
    ];
    return examples.forEach((pair, pairNumber) =>
      context(`pair #${pairNumber}`, function() {
        it(`has request example ID equal to ${pairNumber}`, function() {
          const req = applicationAst.sections[0].resources[0].requests[pairNumber];
          return assert.equal(req.exampleId, pairNumber);
        });
        it(`has response example ID equal to ${pairNumber}`, function() {
          const res = applicationAst.sections[0].resources[0].responses[pairNumber];
          return assert.equal(res.exampleId, pairNumber);
        });
        it(`has request name '${pair.reqName}'`, function() {
          const req = applicationAst.sections[0].resources[0].requests[pairNumber];
          return assert.equal(req.name, pair.reqName);
        });
        return it(`has response status code '${pair.resStatusCode}'`, function() {
          const res = applicationAst.sections[0].resources[0].responses[pairNumber];
          return assert.equal(res.status, pair.resStatusCode);
        });
      })
    );
  })
);
