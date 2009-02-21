require 'test_helper'

class BucketTest < Test::Unit::TestCase
  Bucket = Rack::Mount::Bucket

  def test_basic_hash_operations
    bucket = Bucket.new
    bucket["foo"] = "foo/a"
    bucket["foo"] = "foo/a/b"
    bucket["foo"] = "foo/a/b/c"
    bucket["bar"] = "bar/x"
    bucket["bar"] = "bar/x/y"
    bucket["bar"] = "bar/x/y/z"
    bucket[nil] = "*"
    bucket.freeze

    assert_equal "foo/a", bucket.lookup("foo", "foo/a")
    assert_equal "foo/a/b", bucket.lookup("foo", "foo/a/b")
    assert_equal "foo/a/b/c", bucket.lookup("foo", "foo/a/b/c")

    assert_equal "bar/x", bucket.lookup("bar", "bar/x")
    assert_equal "bar/x/y", bucket.lookup("bar", "bar/x/y")
    assert_equal "bar/x/y/z", bucket.lookup("bar", "bar/x/y/z")

    assert_equal "*", bucket.lookup(nil, "*")
    assert_equal "*", bucket.lookup("foo", "*")
    assert_equal "*", bucket.lookup("bar", "*")

    assert_equal nil, bucket.lookup("foo", "foo/x")
    assert_equal nil, bucket.lookup("bar", "bar/a")
  end

  class TraceQueryKey < Bucket::QueryKey
    attr_reader :calls

    def initialize(*args)
      @calls = []
      super
    end

    def eql?(proxy)
      @calls << proxy.target
      super
    end
  end

  def test_compare_order
    bucket = Bucket.new
    bucket["foo"] = "foo"
    bucket["foo"] = "foo/bar"
    bucket["foo"] = "foo/baz"
    bucket["bar"] = "bar"
    bucket[nil] = "*"
    bucket.freeze

    key = TraceQueryKey.new("foo", "not found")
    assert_equal nil, bucket[key]
    assert_equal ["foo", "foo/bar", "foo/baz", "*"], key.calls

    bucket = Bucket.new
    bucket["foo"] = "foo"
    bucket["bar"] = "bar"
    bucket[nil] = "!"
    bucket["bar"] = "bar/baz"
    bucket[nil] = "*"
    bucket.freeze

    key = TraceQueryKey.new("bar", "not found")
    assert_equal nil, bucket[key]
    assert_equal ["bar", "!", "bar/baz", "*"], key.calls

    key = TraceQueryKey.new("baz", "not found")
    assert_equal nil, bucket[key]
    assert_equal ["!", "*"], key.calls

    bucket = Bucket.new
    bucket["foo"] = "foo"
    bucket["bar"] = "bar"
    bucket[nil] = "*"
    bucket.freeze

    key = TraceQueryKey.new("baz", "not found")
    assert_equal nil, bucket[key]
    assert_equal ["*"], key.calls
  end
end
