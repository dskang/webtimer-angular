describe 'filters', ->

  # load the filter's module
  beforeEach module 'popup'

  describe 'timeString', ->

    # initialize a new instance of the filter before each test
    second = 1
    minute = 60
    hour = 3600
    timeString = null
    beforeEach inject ($filter) ->
      timeString = $filter 'timeString'

    it 'should return singular form', ->
      expect(timeString second).toEqual '1 second'
      expect(timeString minute).toEqual '1 minute'
      expect(timeString hour).toEqual '1 hour'

    it 'should return plural form', ->
      expect(timeString (2 * second)).toEqual '2 seconds'
      expect(timeString (2 * minute)).toEqual '2 minutes'
      expect(timeString (2 * hour)).toEqual '2 hours'

    it 'should not include seconds if > 1 hour', ->
      duration = hour + 2 * minute + 30 * second

      expect(timeString duration).toEqual '1 hour and 2 minutes'

    it 'should not include minutes if 0 minutes', ->
      duration = hour + 15 * second

      expect(timeString duration).toEqual '1 hour'

    it 'should not include seconds if 0 seconds', ->
      duration = 3 * minute

      expect(timeString duration).toEqual '3 minutes'
