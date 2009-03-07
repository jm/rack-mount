require 'test_helper'

class NestedSetTest < Test::Unit::TestCase
  NestedSet = Rack::Mount::NestedSet

  def test_one_level
    root = NestedSet.new

    root["/people"] = "/people"
    root["/people"] = "/people/1"
    root["/people"] = "/people/new"
    root["/companies"] = "/companies"

    assert_equal ["/people", "/people/1", "/people/new"], root["/people"]
    assert_equal ["/companies"], root["/companies"]
    assert_equal [], root["/notfound"]
    assert_equal 3, root.depth
  end

  def test_one_level_with_defaults
    root = NestedSet.new

    root["/people"] = "/people"
    root["/people"] = "/people/1"
    root[nil] = "/:controller/edit"
    root["/people"] = "/people/new"
    root["/companies"] = "/companies"
    root[nil] = "/:controller/:action"

    assert_equal ["/people", "/people/1", "/:controller/edit", "/people/new", "/:controller/:action"], root["/people"]
    assert_equal ["/:controller/edit", "/companies", "/:controller/:action"], root["/companies"]
    assert_equal ["/:controller/edit", "/:controller/:action"], root["/notfound"]
    assert_equal 5, root.depth
  end

  def test_nested_buckets
    root = NestedSet.new

    root["/admin", "/people"] = "/admin/people"
    root["/admin", "/people"] = "/admin/people/1"
    root["/admin", "/people"] = "/admin/people/new"
    root["/admin", "/companies"] = "/admin/companies"

    assert_equal ["/admin/people", "/admin/people/1", "/admin/people/new"], root["/admin", "/people", "/notfound"]
    assert_equal ["/admin/people", "/admin/people/1", "/admin/people/new"], root["/admin", "/people"]
    assert_equal ["/admin/companies"], root["/admin", "/companies"]
    assert_equal [], root["/admin", "/notfound"]
    assert_equal [], root["/notfound"]
    assert_equal 3, root.depth
  end

  def test_nested_buckets_with_defaults
    root = NestedSet.new

    root["/admin"] = "/admin/accounts/new"
    root["/admin", "/people"] = "/admin/people"
    root["/admin", "/people"] = "/admin/people/1"
    root["/admin"] = "/admin/:controller/edit"
    root["/admin", "/people"] = "/admin/people/new"
    root["/admin", "/companies"] = "/admin/companies"
    root[nil, "/companies"] = "/:namespace/companies"
    root[nil] = "/:controller/:action"

    assert_equal ["/admin/accounts/new", "/admin/people", "/admin/people/1", "/admin/:controller/edit", "/admin/people/new", "/:controller/:action"], root["/admin", "/people"]
    assert_equal ["/admin/accounts/new", "/admin/:controller/edit", "/admin/companies", "/:namespace/companies", "/:controller/:action"], root["/admin", "/companies"]
    assert_equal ["/admin/accounts/new", "/admin/:controller/edit", "/:controller/:action"], root["/admin", "/notfound"]
    assert_equal ["/:namespace/companies", "/:controller/:action"], root["/notfound"]
    assert_equal 6, root.depth
  end

  def test_another_nested_buckets_with_defaults
    root = NestedSet.new

    root["GET", "/people"] = "GET /people"
    root[nil, "/people"] = "ANY /people/export"
    root["GET", "/people"] = "GET /people/1"
    root["POST", "/messages"] = "POST /messages"
    root[nil, "/messages"] = "ANY /messages/export"

    assert_equal ["GET /people", "ANY /people/export", "GET /people/1"], root["GET", "/people"]
    assert_equal ["ANY /people/export"], root["POST", "/people"]
    assert_equal ["ANY /people/export", "ANY /messages/export"], root["PUT", "/people"]
    assert_equal ["ANY /messages/export"], root["GET", "/messages"]
    assert_equal ["ANY /people/export", "POST /messages", "ANY /messages/export"], root["POST", "/messages"]

    assert_equal 3, root.depth
  end

  def test_freeze
    root = NestedSet.new

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
