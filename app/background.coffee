config =
  UPDATE_INTERVAL: 3
  IDLE_THRESHOLD: 30

updateData = ->
  chrome.idle.queryState config.IDLE_THRESHOLD, (state) ->
    if state == "active"
      queryInfo =
        active: true
        lastFocusedWindow: true
      chrome.tabs.query queryInfo, (tabs) ->
        if tabs.length
          activeTab = tabs[0]
          console.log activeTab.url
        else
          console.log 'Chrome does not have focus'
    else
      console.log state

setInterval updateData, config.UPDATE_INTERVAL * 1000
