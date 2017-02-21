tablet = window
display = window.open 'display.html', 'display'

tabletLoaded = false
displayLoaded = false
tablet.onload = ->
  tabletLoaded = true
  if displayLoaded then do init
display.onload = ->
  displayLoaded = true
  if tabletLoaded then do init

tablet.onbeforeunload = ->
  display.close()

init = ->
  data =
    tablet:
      loggedIn: false
    display:
      mainScreen: "info"
      secondScreen: null

  tablet.state = data.tablet
  display.state = data.display

  window.tabletVue = new Vue
    el: tablet.document.getElementById("tablet")
    data: data.tablet
    methods:
      login: ->
        # Perform Log in Logic
        data.tablet.loggedIn = true
      launchMaps: ->
        data.display.mainScreen = "maps"
      launchNetflix: ->
        data.display.mainScreen = "netflix"
      launchCamera: ->
        data.display.mainScreen = "camera"
      launchTinder: ->
        data.display.mainScreen = "tinder"
      toggleRearCamera: ->
        screen = data.display.secondScreen
        if screen
          data.display.secondScreen = null
        else
          data.display.secondScreen = "rearCamera"

  infoScreen =
    template: "<div>INFO GOES HERE</div>"

  mapsScreen =
    template: "<div>MAPS GOES HERE</div>"

  netflixScreen =
    template: "<div>NETFLIX GOES HERE</div>"

  cameraScreen =
    template: "<div>CAMERA GOES HERE</div>"

  tinderScreen =
    template: "<div>Tinder GOES HERE</div>"

  rearCameraScreen =
    template: "<div>Rear Camera GOES HERE</div>"

  window.displayVue = new Vue
    el: display.document.getElementById("display")
    data: data.display
    components:
      'info': infoScreen
      'maps': mapsScreen
      'netflix': netflixScreen
      'camera': cameraScreen
      'tinder': tinderScreen
      'rearCamera': rearCameraScreen
    render: (makeEl) ->
      if data.display.secondScreen
        return makeEl("div", [makeEl(data.display.mainScreen), makeEl(data.display.secondScreen)])
      else
        return makeEl(data.display.mainScreen)
