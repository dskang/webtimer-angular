describe "Tracker", ->

  describe "updateLocal", ->

    beforeEach ->
      Tracker.config =
        QUERY_INTERVAL: 3
      spyOn(Tracker.storageArea, 'set')

    it "should create a new entry for a URL that's not been tracked", ->
      spyOn(Tracker.storageArea, 'get').andCallFake (key, callback) ->
        callback {}
      Tracker.updateLocal 'cache', 'http://www.example.com'

      expect(Tracker.storageArea.set).toHaveBeenCalledWith
        cache:
          'http://www.example.com': 3

    it "should update an already existing URL", ->
      spyOn(Tracker.storageArea, 'get').andCallFake (key, callback) ->
        callback
          cache:
            'http://www.example.com': 3
      Tracker.updateLocal 'cache', 'http://www.example.com'

      expect(Tracker.storageArea.set).toHaveBeenCalledWith
        cache:
          'http://www.example.com': 6

  describe "extractDomain", ->

    it "should extract the domain from the URL", ->
      url = 'http://www.example.com/'
      result = Tracker.extractDomain url

      expect(result).toEqual 'example.com'

    it "should extract subdomains from the URL", ->
      url = 'http://subdomain.domain.com/'
      result = Tracker.extractDomain url

      expect(result).toEqual 'subdomain.domain.com'

    it "should not extract the path of the URL", ->
      url = 'http://example.com/this/is/a/path'
      result = Tracker.extractDomain url

      expect(result).toEqual 'example.com'
