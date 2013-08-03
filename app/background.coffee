config =
  QUERY_INTERVAL: 3
  UPDATE_INTERVAL: 60
  IDLE_THRESHOLD: 30
storageArea = chrome.storage.local

queryBrowser = ->
  chrome.idle.queryState config.IDLE_THRESHOLD, (state) ->
    if state == "active"
      queryInfo =
        active: true
        lastFocusedWindow: true
      chrome.tabs.query queryInfo, (tabs) ->
        if tabs.length
          activeTab = tabs[0]
          console.log activeTab.url
          updateLocal activeTab.url

updateLocal = (url) ->
  storageArea.get 'cache', (items) ->
    cache = items.cache ? {}
    cache[url] = 0 unless cache[url]?
    cache[url] += config.QUERY_INTERVAL
    storageArea.set cache: cache

updateServer = ->
  storageArea.get 'cache', (items) ->
    cache = items.cache
    if cache?
      console.log cache
      console.log 'Updating server'
      storageArea.remove 'cache'

setInterval queryBrowser, config.QUERY_INTERVAL * 1000
setInterval updateServer, config.UPDATE_INTERVAL * 1000
