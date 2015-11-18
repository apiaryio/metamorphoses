import lodash from 'lodash';

getUriParameters = (hrefVariable) ->
  return {
    key: "question_id",
    values: [],
    example: "1",
    default: "",
    required: true,
    type: "number",
    description: "<p>ID of the Question in form of an integer<\/p>\n"
  };


module.exports = getUriParameters
