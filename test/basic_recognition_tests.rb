module BasicRecognitionTests
  def test_path
    get "/foo"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:foo, env["tracer"])

    post "/foo"
    assert env
    assert_equal("POST", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:foo, env["tracer"])

    put "/foo"
    assert env
    assert_equal("PUT", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:foo, env["tracer"])

    delete "/foo"
    assert env
    assert_equal("DELETE", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:foo, env["tracer"])
  end

  def test_nested_path
    get "/foo/bar"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:foo_bar, env["tracer"])
  end

  def test_path_mapped_with_leading_slash
    get "/baz"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:baz, env["tracer"])
  end

  def test_path_does_get_shadowed
    get "/people"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:people_index, env["tracer"])

    get "/people/new"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({}, env["rack.routing_args"])
    assert_equal(:people_new, env["tracer"])
  end

  def test_extracts_parameters
    get "/foo/bar/1"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "bar", :id => "1" },
      env["rack.routing_args"])
    assert_equal(:default, env["tracer"])
  end

  def test_extracts_id
    get "/people/1"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :id => "1" }, env["rack.routing_args"])
    assert_equal(:people_show, env["tracer"])

    put "/people/1"
    assert env
    assert_equal("PUT", env["REQUEST_METHOD"])
    assert_equal({ :id => "1" }, env["rack.routing_args"])
    assert_equal(:people_update, env["tracer"])

    delete "/people/1"
    assert env
    assert_equal("DELETE", env["REQUEST_METHOD"])
    assert_equal({ :id => "1" }, env["rack.routing_args"])
    assert_equal(:people_delete, env["tracer"])

    get "/people/2/edit"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :id => "2" }, env["rack.routing_args"])
    assert_equal(:people_edit, env["tracer"])
  end

  def test_path_with_globbing
    get "/files/images/photo.jpg"
    assert env

    # TODO
    # assert_equal({:files => ["images", "photo.jpg"]}, env["rack.routing_args"])
    assert_equal({:files => "images/photo.jpg"}, env["rack.routing_args"])
    assert_equal(:files, env["tracer"])
  end

  def test_not_found
    get "/admin/widgets/show/random"
    assert_nil env
  end
end
