{assert} = require('chai')
getUriParameters = require('../src/adapters/refract/getUriParameters')


describe('Transformation • Refract • getUriParameters' , ->
  context('Transforming URI Parameters without error', ->


    tests = [
      {
        hrefVariables: {
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
        },
        parameters: [
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
      },
      {
        hrefVariables: {
          'element': 'hrefVariables',
          'content': [
            {
              'element': 'member',
              'attributes': {
                'typeAttributes': [
                  'optional'
                ]
              },
              'content': {
                'key': {
                  'element': 'string',
                  'content': 'page'
                },
                'value': {
                  'element': 'enum',
                  'attributes': {
                    'default': [
                      {
                        'element': 'number',
                        'content': 2
                      }
                    ]
                  },
                  'content': [
                    {
                      'element': 'number',
                      'content': 1
                    },
                    {
                      'element': 'number',
                      'content': 2
                    },
                    {
                      'element': 'number',
                      'content': 3
                    }
                  ]
                }
              }
            }
          ]
        },
        parameters: [
          {
                'key': 'page',
                'description': '',
                'type': 'number',
                'required': false,
                'default': '2',
                'example': '',
                'values': [
                    {
                        'value': '1'
                    },
                    {
                        'value': '2'
                    },
                    {
                        'value': '3'
                    }
                ]
            }
        ]
      },
    ]

    it('should be transformed into a `parameter` object', ->
      tests.map((test) ->
        assert.deepEqual(getUriParameters(test.hrefVariables), test.parameters)
      )
    )
  )
)
