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

  @queryBrowser: =>
    chrome.idle.queryState @config.IDLE_THRESHOLD, (state) =>
      if state == 'active'
        queryInfo =
          active: true
          lastFocusedWindow: true
        chrome.tabs.query queryInfo, (tabs) =>
          if tabs.length
            activeTab = tabs[0]
            console.log "Current URL: #{activeTab.url}"
            if Tracker.validateUrl activeTab.url
              @updateLocal 'cache', activeTab.url
              @updateLocal 'today', @extractDomain activeTab.url

  @updateLocal: (key, url) ->
    @storageArea.get key, (items) =>
      items[key] ?= {}
      store = items[key]
      store[url] = 0 unless store[url]?
      store[url] += @config.QUERY_INTERVAL
      @storageArea.set items

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

class Keeper
  @storageArea: chrome.storage.local

  @moveData: (oldKey, newKey) ->
    @storageArea.get [oldKey, newKey], (items) =>
      oldStore = items[oldKey]
      if oldStore?
        items[newKey] ?= {}
        newStore = items[newKey]
        for domain, duration of oldStore
          newStore[domain] ?= 0
          newStore[domain] += duration
        items[oldKey] = {}
        @storageArea.set items

init = ->
  test_env = window.location.pathname != '/background.html'
  if test_env
    window.Tracker = Tracker
    window.LoginCtrl = LoginCtrl
    window.Keeper = Keeper
  else
    window.setInterval Tracker.queryBrowser, Tracker.config.QUERY_INTERVAL * 1000
    window.setInterval Tracker.updateServer, Tracker.config.UPDATE_INTERVAL * 1000

  chrome.runtime.onInstalled.addListener (details) ->
    LoginCtrl.registerUser() unless test_env

init()
