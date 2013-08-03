config =
  QUERY_INTERVAL: 3
  UPDATE_INTERVAL: 60
  IDLE_THRESHOLD: 30

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
        else
          console.log 'Chrome does not have focus'
    else
      console.log state

updateLocal = (url) ->
  storageArea = chrome.storage.local
  storageArea.get 'cache', (items) ->
    cache = items.cache ? {}
    cache[url] = 0 unless cache[url]?
    cache[url] += config.QUERY_INTERVAL
    storageArea.set cache: cache

updateServer = ->
  console.log 'updating server'

setInterval queryBrowser, config.QUERY_INTERVAL * 1000
setInterval updateServer, config.UPDATE_INTERVAL * 1000
