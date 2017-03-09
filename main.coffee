tablet = window
display = window.open 'display.html', 'display'

display.document.readyState = null

init = ->
  data =
    tablet:
      loggedIn: false
      currentApp: null
    display:
      mainScreen: "info"
      rearCameraEnabled: false

  tablet.state = data.tablet
  display.state = data.display

  window.tabletVue = new Vue
    el: tablet.document.getElementById("tablet")
    data: data.tablet
    methods:
      login: ->
        data.tablet.loggedIn = true
      launchApp: (app) ->
        data.display.mainScreen = app
        data.tablet.currentApp = app
      closeApp: ->
        data.display.mainScreen = 'info'
        data.tablet.currentApp = null
      toggleRearCamera: ->
        data.display.rearCameraEnabled = !data.display.rearCameraEnabled

  infoScreen =
    template: display.document.getElementById("info")

  mapsScreen =
    template: display.document.getElementById("maps")

  netflixScreen =
    template: display.document.getElementById("netflix")

  cameraScreen =
    template: display.document.getElementById("camera")
    beforeMount: loadFrontCamera
    beforeDestroy: unloadFrontCamera

  tinderScreen =
    template: display.document.getElementById("tinder-template")

  rearCameraScreen =
    template: display.document.getElementById("rear-camera-template")
    beforeMount: loadRearCamera
    beforeDestroy: unloadRearCamera

  window.displayVue = new Vue
    el: display.document.getElementById("display")
    data: data.display
    components:
      'info': infoScreen
      'maps': mapsScreen
      'netflix': netflixScreen
      'camera': cameraScreen
      'tinder': tinderScreen
      'rear-camera': rearCameraScreen

loadFrontCamera = ->
  console.log "Loading Front Camera"
  display.navigator.mediaDevices.getUserMedia(
    video:
      deviceId: frontCamera
  ).then((stream) ->
    display.frontStream = stream
    display.document.querySelector('#front-video').srcObject = stream)

unloadFrontCamera = ->
  console.log "Unloading Front Camera"
  for track in display.frontStream.getTracks()
    track.stop()

loadRearCamera = ->
  console.log "Loading Rear Camera"
  display.navigator.mediaDevices.getUserMedia(
    video:
      deviceId: backCamera
  ).then((stream) ->
    display.rearStream = stream
    display.document.querySelector('#rear-video').srcObject = stream
  )

unloadRearCamera = ->
  console.log "Unloading Rear Camera"
  for track in display.rearStream.getTracks()
    track.stop()

backCamera = null
frontCamera = null

tabletLoaded = new Promise((r, _) ->
  if tablet.document.readyState is "complete" then do r else tablet.onload = r
)

displayLoaded = new Promise((r, _) ->
  display.onload = r
)

camerasLoaded = new Promise((resolve, reject) ->
  navigator.mediaDevices.enumerateDevices().then((devices) ->
    devices = devices.filter((d) -> d.kind is "videoinput")
    for device in devices
      console.log "Found Camera:", device.label
      if device.label is 'Microsoft Camera Rear'
        backCamera = device.deviceId
      if device.label is 'Microsoft Camera Front'
        frontCamera = device.deviceId
    do resolve
  ).catch(reject)
)

Promise.all([tabletLoaded, displayLoaded, camerasLoaded]).then(init)

tablet.onbeforeunload = ->
  display.close()
