class Tracker
  @config:
    QUERY_INTERVAL: 3
    UPDATE_INTERVAL: 60
    IDLE_THRESHOLD: 30

  @storageArea: chrome.storage.local

  @extractDomain: (url) ->
    re = /:\/\/(?:www\.)?(.+?)\//
    url.match(re)[1]

  @validateUrl: (url) ->
    /^http/.test url

  @updateBadge: (seconds) ->
    minutes = Math.floor(seconds / 60)
    chrome.browserAction.setBadgeText
      text: "#{minutes}m"

  @queryBrowser: =>
    chrome.idle.queryState @config.IDLE_THRESHOLD, (state) =>
      if state == 'active'
        queryInfo =
          active: true
          lastFocusedWindow: true
        chrome.tabs.query queryInfo, (tabs) =>
          if tabs.length
            activeTab = tabs[0]
            if Tracker.validateUrl activeTab.url
              DateManager.checkDate =>
                @updateLocal ['cache'], activeTab.url
                @updateLocal ['today', 'week', 'month', 'allTime'], @extractDomain activeTab.url
            else
              chrome.browserAction.setBadgeText
                text: ''

  @updateLocal: (keys, url) ->
    @storageArea.get keys, (items) =>
      for key in keys
        items[key] ?= {}
        store = items[key]
        store[url] ?= 0
        store[url] += @config.QUERY_INTERVAL
        @storageArea.set items
        @updateBadge store[url] if key == 'today'

  @updateServer: =>
    @storageArea.get 'cache', (items) =>
      cache = items.cache
      if cache?
        console.log 'Updating server with cache:'
        console.log cache
        @storageArea.remove 'cache'

class LoginCtrl
  @registerUser: ->
    googleAuth = new OAuth2 'google',
      client_id: '50343319776-05t7b2687b6uq4e425oasfedoq043ank.apps.googleusercontent.com'
      client_secret: '_MqLaCWyacnUAEh6hdx5L-J0'
      api_scope: 'https://www.googleapis.com/auth/userinfo.email'

    googleAuth.authorize =>
      email = @getEmail googleAuth.getAccessToken()
      @sendUserInfo email, googleAuth.getAccessToken()

  @getEmail: (access_token) ->
    request = new XMLHttpRequest()
    request.open 'GET', "https://www.googleapis.com/oauth2/v2/userinfo?access_token=#{access_token}", false
    request.send()
    if request.status == 200
      response = JSON.parse request.responseText
      response.email

  @sendUserInfo: (email, access_token) ->
    console.log 'Registering user: ', email, access_token

class DateManager
  @storageArea: chrome.storage.local

  @checkDate: (callback) ->
    @storageArea.get 'date', (items) =>
      if items.date?
        dateChanges = @dateChange new Date(items.date), new Date()
        if dateChanges.length > 0
          console.log 'dateChange'
          if 'day' in dateChanges
            items.today = {}
          if 'week' in dateChanges
            items.week = {}
          if 'month' in dateChanges
            items.month = {}
          items.date = (new Date()).toLocaleDateString()
          @storageArea.set items, callback
        else
          callback()
      else
        items.date = (new Date()).toLocaleDateString()
        @storageArea.set items, callback

  @dateChange: (oldDate, newDate) ->
    numDaysChanged = @numDaysChanged oldDate, newDate
    yearChanged = newDate.getFullYear() != oldDate.getFullYear()
    monthChanged = yearChanged or newDate.getMonth() != oldDate.getMonth()
    weekChanged = newDate.getDay() < oldDate.getDay() or numDaysChanged > 7
    dayChanged = numDaysChanged > 0

    changes = []
    changes.push 'month' if monthChanged
    changes.push 'week' if weekChanged
    changes.push 'day' if dayChanged
    changes

  @numDaysChanged: (oldDate, newDate) ->
    midnightOldDate = new Date oldDate.toLocaleDateString()
    midnightNewDate = new Date newDate.toLocaleDateString()
    (midnightNewDate.getTime() - midnightOldDate.getTime()) / (1000 * 60 * 60 * 24)

init = ->
  test_env = window.jasmine?
  if test_env
    window.Tracker = Tracker
    window.LoginCtrl = LoginCtrl
    window.DateManager = DateManager
  else
    window.setInterval Tracker.queryBrowser, Tracker.config.QUERY_INTERVAL * 1000
    window.setInterval Tracker.updateServer, Tracker.config.UPDATE_INTERVAL * 1000

  chrome.runtime.onInstalled.addListener (details) ->
    LoginCtrl.registerUser() unless test_env

init()
