class Tracker
  @config:
    QUERY_INTERVAL: 3
    UPDATE_INTERVAL: 60
    IDLE_THRESHOLD: 30
    OFFLINE_MODE: true

  @storageArea: chrome.storage.local

  @queryBrowser: =>
    chrome.idle.queryState @config.IDLE_THRESHOLD, (state) =>
      if state == 'active'
        queryInfo =
          active: true
          lastFocusedWindow: true
        chrome.tabs.query queryInfo, (tabs) =>
          if tabs.length
            activeTab = tabs[0]
            console.log activeTab.url
            @updateLocal activeTab.url

  @updateLocal: (url) ->
    store = if @config.OFFLINE_MODE then 'today' else 'cache'
    @storageArea.get store, (items) =>
      items[store] ?= {}
      store = items[store]
      store[url] = 0 unless store[url]?
      store[url] += @config.QUERY_INTERVAL
      @storageArea.set items

  @updateServer: =>
    @storageArea.get 'cache', (items) =>
      cache = items.cache
      if cache?
        console.log cache
        console.log 'Updating server'
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

init = ->
  test_env = window.location.pathname != '/background.html'
  unless test_env
    window.setInterval Tracker.queryBrowser, Tracker.config.QUERY_INTERVAL * 1000
    window.setInterval Tracker.updateServer, Tracker.config.UPDATE_INTERVAL * 1000 unless Tracker.config.OFFLINE_MODE

  chrome.runtime.onInstalled.addListener (details) ->
    LoginCtrl.registerUser() unless Tracker.config.OFFLINE_MODE

init()
