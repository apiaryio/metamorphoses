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
                    'samples': [
                      [
                        {
                          'element': 'number',
                          'content': 2
                        }
                      ]
                    ],
                    'default': [
                      {
                        'element': 'number',
                        'content': 1
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
            'type': 'enum',
            'required': false,
            'default': '1',
            'example': '2',
            'values': [
                '1',
                '2',
                '3'
            ]
          }
        ]
      },
      # Parameter is optional by default with no type attributes
      {
        hrefVariables: {
          'element': 'hrefVariables',
          'content': [
            {
              'element': 'member',
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
            'description': '',
            'type': 'number',
            'required': false,
            'default': '',
            'example': '1',
            'values': [
            ]
          }
        ]
      },
      {
        hrefVariables: undefined,
        parameters: undefined,
      },
      {
        hrefVariables: {
          'element': 'hrefVariables',
          'content': [
            {
              'element': 'member',
              'meta': {
                'title': 'datetime',
                'description': 'Filter for posts since the specified date'
              },
              'content': {
                'key': {
                  'element': 'string',
                  'content': 'since'
                },
                'value': {
                  'element': 'string',
                  'content': 'thursday'
                }
              }
            }
          ]
        },
        parameters: [
          {
            'key': 'since',
            'description': '<p>Filter for posts since the specified date</p>\n',
            'type': 'datetime',
            'required': false,
            'default': '',
            'example': 'thursday',
            'values': [
            ]
          }
        ]
      },
      {
        hrefVariables: {
          "element": "hrefVariables",
          "meta": {},
          "attributes": {},
          "content": [
            {
              "element": "member",
              "meta": {},
              "attributes": {},
              "content": {
                "key": {
                  "element": "string",
                  "meta": {},
                  "attributes": {},
                  "content": "filters"
                },
                "value": {
                  "element": "array",
                  "meta": {},
                  "attributes": {},
                  "content": [
                    {
                      "element": "enum",
                      "meta": {},
                      "attributes": {},
                      "content": [
                        {
                          "element": "string",
                          "meta": {},
                          "attributes": {},
                          "content": "wifi"
                        },
                        {
                          "element": "string",
                          "meta": {},
                          "attributes": {},
                          "content": "accept_cards"
                        },
                        {
                          "element": "string",
                          "meta": {},
                          "attributes": {},
                          "content": "open_now"
                        }
                      ]
                    }
                  ]
                }
              }
            }
          ]
        },
        parameters: [{
          "default": ""
          "description": ""
          "example": ""
          "key": "filters"
          "required": false
          "type": "array"
          "values": [
            "wifi",
            "accept_cards",
            "open_now"
          ]
        }]
      },
      # Sample and default attributes specify no content, just type
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
                    'samples': {
                      'element': 'number',
                    },
                    'default': {
                      'element': 'number',
                    }
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
            'type': 'enum',
            'required': false,
            'default': '',
            'example': '',
            'values': [
                '1',
                '2',
                '3'
            ]
          }
        ]
      },
      # Default attribute's content is empty array
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
                  'element': 'array',
                  'attributes': {
                    'samples': {
                      'element': 'array',
                    },
                    'default': {
                      'content': [],
                      'element': 'array',
                    }
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
            'type': 'array',
            'required': false,
            'default': [],
            'example': '',
            'values': [
                '1',
                '2',
                '3'
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
