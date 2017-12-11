minim = require('minim').namespace().use(require('minim-parse-result'))
JSON06Serialiser = require('minim/lib/serialisers/json-0.6')

minim.serialiser06 = new JSON06Serialiser(minim)

module.exports = minim
