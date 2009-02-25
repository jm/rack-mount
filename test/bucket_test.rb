require 'test_helper'

class BucketTest < Test::Unit::TestCase
  Bucket = Rack::Mount::Bucket

  def test_one_level
    root = Bucket.new

    root["/people"] = "/people"
    root["/people"] = "/people/1"
    root["/people"] = "/people/new"
    root["/companies"] = "/companies"

    assert_equal ["/people", "/people/1", "/people/new"], root["/people"]
    assert_equal ["/companies"], root["/companies"]
    assert_equal [], root["/notfound"]
  end

  def test_one_level_with_defaults
    root = Bucket.new

    root["/people"] = "/people"
    root["/people"] = "/people/1"
    root[nil] = "/:controller/edit"
    root["/people"] = "/people/new"
    root["/companies"] = "/companies"
    root[nil] = "/:controller/:action"

    assert_equal ["/people", "/people/1", "/:controller/edit", "/people/new", "/:controller/:action"], root["/people"]
    assert_equal ["/:controller/edit", "/companies", "/:controller/:action"], root["/companies"]
    assert_equal ["/:controller/edit", "/:controller/:action"], root["/notfound"]
  end

  def test_nested_buckets
    root = Bucket.new

    root["/admin", "/people"] = "/admin/people"
    root["/admin", "/people"] = "/admin/people/1"
    root["/admin", "/people"] = "/admin/people/new"
    root["/admin", "/companies"] = "/admin/companies"

    assert_equal ["/admin/people", "/admin/people/1", "/admin/people/new"], root["/admin", "/people", "/notfound"]
    assert_equal ["/admin/people", "/admin/people/1", "/admin/people/new"], root["/admin", "/people"]
    assert_equal ["/admin/companies"], root["/admin", "/companies"]
    assert_equal [], root["/admin", "/notfound"]
    assert_equal [], root["/notfound"]
  end

  def test_nested_buckets_with_defaults
    root = Bucket.new

    root["/admin", "/people"] = "/admin/people"
    root["/admin", "/people"] = "/admin/people/1"
    root["/admin"] = "/admin/:controller/edit"
    root["/admin", "/people"] = "/admin/people/new"
    root["/admin", "/companies"] = "/admin/companies"
    root[nil] = "/:controller/:action"

    assert_equal ["/admin/people", "/admin/people/1", "/admin/:controller/edit", "/admin/people/new", "/:controller/:action"], root["/admin", "/people"]
    assert_equal ["/admin/:controller/edit", "/admin/companies", "/:controller/:action"], root["/admin", "/companies"]
    assert_equal ["/admin/:controller/edit", "/:controller/:action"], root["/admin", "/notfound"]
    assert_equal ["/:controller/:action"], root["/notfound"]
  end

  def test_freeze
    root = Bucket.new

    root["/admin", "/people"] = "/admin/people"
    root["/admin", "/people"] = "/admin/people/1"
    root["/admin"] = "/admin/:controller/edit"
    root["/admin", "/people"] = "/admin/people/new"
    root["/admin", "/companies"] = "/admin/companies"
    root[nil] = "/:controller/:action"

    root.freeze

    assert root.frozen?
    assert root["/admin"].frozen?
    assert root["/notfound"].frozen?
    assert root["/admin", "/people"].frozen?
    root["/admin", "/people"].each { |e|
      assert e.frozen?
    }
  end
end
