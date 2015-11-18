{assert} = require('chai')
getUriParameters = require('../src/adapters/refract/getUriParameters')


describe('Transformation • Refract • getUriParameters' , ->
  context('Transforming URI Parameters without error', ->

    uriParameters = undefined

    hrefVariables = {
      'element': 'hrefVariables',
      'content': [
        {
          'element': 'member',
          'meta': {
            'description': 'ID of the Question in form of an integer'
          },
          'attributes': {
            'typeAttributes': [
              'required'
            ]
          },
          'content': {
            'key': {
              'element': 'string',
              'content': 'question_id'
            },
            'value': {
              'element': 'number',
              'content': 1
            }
          }
        }
      ]
    }

    parameters = [
      {
        'key': 'question_id',
        'description': '<p>ID of the Question in form of an integer</p>\n',
        'type': 'number',
        'required': true,
        'default': '',
        'example': '1',
        'values': [
        ]
      }
    ]

    before( ->
      uriParameters = getUriParameters(hrefVariables)
    )

    it('should be transformed into a `parameter` object', ->
      assert.deepEqual(uriParameters, parameters)
    )
  )
)
