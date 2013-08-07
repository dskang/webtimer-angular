describe "Tracker", ->

  describe "updateLocal", ->

    beforeEach ->
      Tracker.config =
        QUERY_INTERVAL: 3
      spyOn(Tracker.storageArea, 'set')

    it "should create a new entry for a URL that's not been tracked", ->
      spyOn(Tracker.storageArea, 'get').andCallFake (key, callback) ->
        callback {}
      Tracker.updateLocal ['today', 'week', 'month', 'allTime'], 'http://www.example.com'

      expect(Tracker.storageArea.set).toHaveBeenCalledWith
        today:
          'http://www.example.com': 3
        week:
          'http://www.example.com': 3
        month:
          'http://www.example.com': 3
        allTime:
          'http://www.example.com': 3

    it "should update an already existing URL", ->
      spyOn(Tracker.storageArea, 'get').andCallFake (key, callback) ->
        callback
          month:
            'http://www.example.com': 6
          allTime:
            'http://www.example.com': 6
      Tracker.updateLocal ['today', 'week', 'month', 'allTime'], 'http://www.example.com'

      expect(Tracker.storageArea.set).toHaveBeenCalledWith
        today:
          'http://www.example.com': 3
        week:
          'http://www.example.com': 3
        month:
          'http://www.example.com': 9
        allTime:
          'http://www.example.com': 9

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

  describe "validateUrl", ->

    it "should return true for HTTP and HTTPS URLs", ->
      httpUrlResult = Tracker.validateUrl 'http://www.example.com/'
      httpsUrlResult = Tracker.validateUrl 'https://www.example.com/'

      expect(httpUrlResult).toBe true
      expect(httpsUrlResult).toBe true

    it "should return false for non-HTTP URLs", ->
      result = Tracker.validateUrl 'chrome://extensions/'

      expect(result).toBe false

describe "DateManager", ->

  describe "checkDate", ->

    beforeEach ->
      spyOn(DateManager.storageArea, 'get').andCallFake (key, callback) ->
        callback
          date: '7/22/1992' # date doesn't matter as only dateChange changes behavior
      spyOn(DateManager.storageArea, 'set')

    it "should save today's date if none already saved", ->
      DateManager.storageArea.get.andCallFake (key, callback) ->
        callback {}
      DateManager.checkDate()

      expect(DateManager.storageArea.set).toHaveBeenCalledWith
        date: (new Date()).toLocaleDateString()

    it "should reset today on a new day", ->
      spyOn(DateManager, 'dateChange').andReturn ['day']
      DateManager.checkDate()

      expect(DateManager.storageArea.set).toHaveBeenCalledWith
        date: (new Date()).toLocaleDateString()
        today: {}

    it "should reset today and week on a new week", ->
      spyOn(DateManager, 'dateChange').andReturn ['week', 'day']
      DateManager.checkDate()

      expect(DateManager.storageArea.set).toHaveBeenCalledWith
        date: (new Date()).toLocaleDateString()
        week: {}
        today: {}

    it "should reset today, week, and month on a new month", ->
      spyOn(DateManager, 'dateChange').andReturn ['month', 'week', 'day']
      DateManager.checkDate()

      expect(DateManager.storageArea.set).toHaveBeenCalledWith
        date: (new Date()).toLocaleDateString()
        month: {}
        week: {}
        today: {}

  describe "numDaysChanged", ->
    oldDate = null

    beforeEach ->
      oldDate = new Date 1992, 6, 22 # Wed, July 22, 1992

    it "should count no changes", ->
      newDate = new Date 1992, 6, 22, 22, 30, 30
      numDaysChanged = DateManager.numDaysChanged oldDate, newDate

      expect(numDaysChanged).toEqual 0

    it "should count days changed", ->
      newDate = new Date 1992, 6, 25
      numDaysChanged = DateManager.numDaysChanged oldDate, newDate

      expect(numDaysChanged).toEqual 3

  describe "dateChange", ->
    oldDate = null

    beforeEach ->
      oldDate = new Date 1992, 6, 22 # Wed, July 22, 1992

    it "should detect no change", ->
      newDate = new Date 1992, 6, 22
      changes = DateManager.dateChange oldDate, newDate

      expect(changes).toEqual []

    it "should detect changes in day", ->
      newDate = new Date 1992, 6, 24
      changes = DateManager.dateChange oldDate, newDate

      expect(changes.length).toEqual 1
      expect(changes).toContain 'day'

    it "should detect changes in week", ->
      newDate = new Date 1992, 6, 30 # Thurs
      changes = DateManager.dateChange oldDate, newDate

      expect(changes.length).toEqual 2
      expect(changes).toContain 'week'
      expect(changes).toContain 'day'

    it "should detect changes in week on a Sunday", ->
      newDate = new Date 1992, 6, 26 # Sun
      changes = DateManager.dateChange oldDate, newDate

      expect(changes.length).toEqual 2
      expect(changes).toContain 'week'
      expect(changes).toContain 'day'

    it "should detect changes in month", ->
      newDate = new Date 1992, 7, 1
      changes = DateManager.dateChange oldDate, newDate

      expect(changes.length).toEqual 3
      expect(changes).toContain 'month'
      expect(changes).toContain 'week'
      expect(changes).toContain 'day'

    it "should treat changes in year as changes in month", ->
      newDate = new Date 1993, 6, 22
      changes = DateManager.dateChange oldDate, newDate

      expect(changes.length).toEqual 3
      expect(changes).toContain 'month'
      expect(changes).toContain 'week'
      expect(changes).toContain 'day'

    it "should detect changes in month but not in week", ->
      oldDate = new Date 1992, 6, 31 # Friday
      newDate = new Date 1992, 7, 1 # Saturday
      changes = DateManager.dateChange oldDate, newDate

      expect(changes.length).toEqual 2
      expect(changes).toContain 'month'
      expect(changes).toContain 'day'
