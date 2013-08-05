describe "foo", ->
  foo = null

  beforeEach ->
    foo = 0
    foo += 1

  afterEach ->
    foo = 0

  it "should be equal 1", ->
    expect(foo).toEqual 1
