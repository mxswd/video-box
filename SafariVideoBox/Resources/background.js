browser.pageAction.onClicked.addListener((tab) => {
  browser.tabs.update({url: `videoboxgo:///openURL?url=${encodeURIComponent(tab.url)}`});
    
});

browser.pageAction.onClicked.addListener(function () {
});
