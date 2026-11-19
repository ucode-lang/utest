import { describe, it, assert, mock } from 'utest';
import { full_match, dirname } from 'utest.util';
import { path_str } from 'utest.combinators';

// Newline-bearing input must behave the same on every regex engine. libucode
// 2026.07.09 made ^/$ match per line and stopped '.'/'[^...]' matching '\n', which
// silently changed every anchored /^...$/ check. Run under both engines.

describe('full_match()', () => {
	it('accepts a string the pattern covers entirely', () => {
		assert.match(true, full_match("123", /^[0-9]+$/));
	});

	it('rejects a string whose first line alone matches', () => {
		assert.match(false, full_match("2\nx", /^[0-9]+$/));
	});

	it('rejects a string whose last line alone matches', () => {
		assert.match(false, full_match("x\n2", /^[0-9]+$/));
	});

	it('rejects non-strings', () => {
		assert.match(false, full_match(null, /^.*$/));
		assert.match(false, full_match(42, /^[0-9]+$/));
	});
});

describe('dirname()', () => {
	it('strips the last component', () => {
		assert.match("/a/b", dirname("/a/b/c.uc"));
	});

	it('keeps a newline that sits inside the last component', () => {
		assert.match("/x", dirname("/x/a\nb"));
	});

	it('returns the input when there is no slash or a trailing one', () => {
		assert.match("file.uc", dirname("file.uc"));
		assert.match("/a/", dirname("/a/"));
	});

	it('returns an empty string for a top-level path', () => {
		assert.match("", dirname("/a"));
	});
});

describe('path_str()', () => {
	it('quotes a key containing a newline', () => {
		assert.match('["a\\nb"]', path_str(["a\nb"]));
	});

	it('dots a plain identifier key', () => {
		assert.match("user.age", path_str(["user", "age"]));
	});
});

describe('fs.glob() mock with newline paths', () => {
	const data = { '/v/x\ny': 'n', '/v/z': 'z' };

	it("'*' matches across a newline in the component", () => {
		mock.inject('fs', { data }, (m_fs) => {
			assert.match(['/v/x\ny', '/v/z'], m_fs.glob('/v/*'));
		});
	});

	it("'?' matches a newline", () => {
		mock.inject('fs', { data }, (m_fs) => {
			assert.match(['/v/x\ny'], m_fs.glob('/v/x?y'));
		});
	});

	it('a negated class matches a newline', () => {
		mock.inject('fs', { data }, (m_fs) => {
			assert.match(['/v/x\ny'], m_fs.glob('/v/x[!q]y'));
		});
	});

	it('a literal pattern does not match a path that only starts with it', () => {
		mock.inject('fs', { data }, (m_fs) => {
			assert.match(null, m_fs.glob('/v/x'));
		});
	});
});
