describe "Tracker", ->
  describe "updateLocal", ->
    beforeEach ->
      Tracker.config =
        OFFLINE_MODE: true
        QUERY_INTERVAL: 3
      spyOn(Tracker.storageArea, 'set')

    it "should create a new entry for a URL that's not been tracked", ->
      spyOn(Tracker.storageArea, 'get').andCallFake (key, callback) ->
        callback {}
      Tracker.updateLocal 'http://www.example.com'

      expect(Tracker.storageArea.set).toHaveBeenCalledWith
        today:
          'http://www.example.com': 3

    it "should update an already existing URL", ->
      spyOn(Tracker.storageArea, 'get').andCallFake (key, callback) ->
        callback
          today:
            'http://www.example.com': 3
      Tracker.updateLocal 'http://www.example.com'

      expect(Tracker.storageArea.set).toHaveBeenCalledWith
        today:
          'http://www.example.com': 6
