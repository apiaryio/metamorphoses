/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {assert} = require('chai');
const markdown = require('../src/adapters/markdown');

describe('Markdown rendered', () =>
  describe('#toHtml', function() {
    it('Parse a plain paragraph', function(done) {
      const markdownString = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
      const expectedHtml = '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>\n';

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse a bullet list (stars used as bullets)', function(done) {
      const markdownString = `\
* Red
* Green
* Orange
* Blue\
`;

      const expectedHtml = `\
<ul>
<li>Red</li>
<li>Green</li>
<li>Orange</li>
<li>Blue</li>
</ul>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse a bullet list (dashes used as bullets)', function(done) {
      const markdownString = `\
- Red
- Green
- Orange
- Blue\
`;

      const expectedHtml = `\
<ul>
<li>Red</li>
<li>Green</li>
<li>Orange</li>
<li>Blue</li>
</ul>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse an ordered list', function(done) {
      const markdownString = `\
1. Red
2. Green
3. Orange
4. Blue\
`;

      const expectedHtml = `\
<ol>
<li>Red</li>
<li>Green</li>
<li>Orange</li>
<li>Blue</li>
</ol>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse nested lists', function(done) {
      const markdownString = `\
* Lorem
* Ipsum
  * Dolor
  * Ismaet\
`;

      const expectedHtml = `\
<ul>
<li>Lorem</li>
<li>Ipsum
<ul>
<li>Dolor</li>
<li>Ismaet</li>
</ul>
</li>
</ul>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse headers', function(done) {
      const markdownString = `\
# Level 1
## Level 2
### Level 3
#### Level 4
##### Level 5
###### Level 6\
`;

      const expectedHtml = `\
<h1>Level 1</h1>
<h2>Level 2</h2>
<h3>Level 3</h3>
<h4>Level 4</h4>
<h5>Level 5</h5>
<h6>Level 6</h6>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse a code block', function(done) {
      const markdownString = `\
Lorem ipsum dolor isamet.

    alert('Hello!');\
`;

      const expectedHtml = `\
<p>Lorem ipsum dolor isamet.</p>
<pre><code>alert('Hello!');</code></pre>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse a fenced code block', function(done) {
      const markdownString = `\
\`\`\`
alert('Hello!');
\`\`\`\
`;

      const expectedHtml = `\
<pre><code>alert('Hello!');
</code></pre>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    it('Parse a Markdown table', function(done) {
      const markdownString = `\
| First Header  | Second Header | Third Header         |
| :------------ | :-----------: | -------------------: |
| First row     | Data          | Very long data entry |
| Second row    | **Cell**      | *Cell*               |
| Third row     | Cell that spans across two columns  ||\
`;

      const expectedHtml = `\
<table>
<thead>
<tr>
<th align="left">First Header</th>
<th align="center">Second Header</th>
<th align="right">Third Header</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left">First row</td>
<td align="center">Data</td>
<td align="right">Very long data entry</td>
</tr>
<tr>
<td align="left">Second row</td>
<td align="center"><strong>Cell</strong></td>
<td align="right"><em>Cell</em></td>
</tr>
<tr>
<td align="left">Third row</td>
<td align="center">Cell that spans across two columns</td>
<td align="right"></td>
</tr>
</tbody>
</table>
\
`;

      return markdown.toHtml(markdownString, function(error, html) {
        assert.strictEqual(html, expectedHtml);
        return done(error);
      });
    });

    describe('when sanitize is true', function() {
      it('Parse out script tags', function(done) {
        const markdownString = `\
<div><script>HTML tag</script></div>\
`;

        const expectedHtml = `\
<div></div>
\
`;

        return markdown.toHtml(markdownString, function(error, html) {
          assert.strictEqual(html, expectedHtml);
          return done(error);
        });
      });

      it('Parse out custom tags and preserve contents', function(done) {
        const markdownString = `\
<p><custom>HTML tag</custom></p>\
`;

        const expectedHtml = `\
<p>HTML tag</p>
\
`;

        return markdown.toHtml(markdownString, function(error, html) {
          assert.strictEqual(html, expectedHtml);
          return done(error);
        });
      });

      it('Parse out custom attributes', function(done) {
        const markdownString = `\
<p custom="test">HTML tag</p>\
`;

        const expectedHtml = `\
<p>HTML tag</p>
\
`;

        return markdown.toHtml(markdownString, function(error, html) {
          assert.strictEqual(html, expectedHtml);
          return done(error);
        });
      });

      it('Parse preseves code block tags', function(done) {
        const markdownString = `\
\`\`\`xml
<xml>Hello World</xml>
\`\`\`\
`;

        const expectedHtml = `\
<pre><code class="xml">&lt;xml&gt;Hello World&lt;/xml&gt;\n</code></pre>
\
`;

        return markdown.toHtml(markdownString, function(error, html) {
          assert.strictEqual(html, expectedHtml);
          return done(error);
        });
      });

      return it('Parse and sanitize images', function(done) {
        const markdownString = `\
<img src="/image.jpg" onerror="alert('XSS')" />\
`;

        const expectedHtml = `\
<img src="/image.jpg">
\
`;

        return markdown.toHtml(markdownString, function(error, html) {
          assert.strictEqual(html, expectedHtml);
          return done(error);
        });
      });
    });

    return describe('when sanitizing is false', function() {
      it('Parse and leave script tags', function(done) {
        const markdownString = `\
<div><script>HTML tag</script></div>\
`;

        const expectedHtml = `\
<div><script>HTML tag</script></div>
\
`;

        return markdown.toHtml(markdownString, {sanitize: false}, function(error, html) {
          assert.strictEqual(html, expectedHtml);
          return done(error);
        });
      });

      return it('Parse and leave custom tags and preserve contents', function(done) {
        const markdownString = `\
<p><custom>HTML tag</custom></p>\
`;

        const expectedHtml = `\
<p><custom>HTML tag</custom></p>
\
`;

        return markdown.toHtml(markdownString, {sanitize: false}, function(error, html) {
          assert.strictEqual(html, expectedHtml);
          return done(error);
        });
      });
    });
  })
);
