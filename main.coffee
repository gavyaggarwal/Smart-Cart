tablet = window
display = window.open 'display.html', 'display'

display.document.readyState = null

init = ->
  data =
    tablet:
      loggedIn: false
      currentApp: null
      rearCameraEnabled: false
      netflix:
        isPlaying: false
        title: null
        upgrade: false
        paused: false
      camera:
        img: ""
    display:
      mainScreen: "info"
      rearCameraEnabled: false
      netflix:
        isPlaying: false
        file: null
      maps:
        timer: null
        location: [0, 0]

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
        data.tablet.rearCameraEnabled = !data.tablet.rearCameraEnabled
        data.display.rearCameraEnabled = !data.display.rearCameraEnabled
      chooseMovie: (title, file, paid) ->
        data.tablet.netflix.upgrade = paid
        data.tablet.netflix.isPlaying = !paid
        data.display.netflix.isPlaying = !paid
        data.tablet.netflix.title = title
        data.display.netflix.file = file
        data.display.netflix.paused = false
      togglePause: ->
        data.tablet.netflix.paused = !data.tablet.netflix.paused
        if data.tablet.netflix.paused
          display.document.querySelector('#netflix video').pause()
        else
          display.document.querySelector('#netflix video').play()
      skipInVideo: (time) ->
        video = display.document.querySelector('#netflix video')
        video.currentTime += time
      takePicture: ->
        video = display.document.querySelector('#front-video')
        canvas = tablet.document.querySelector('canvas')

        canvas.width  = 640;
        canvas.height = 480;
        canvas.getContext('2d').drawImage(video, 0, 0, 640, 480)
        imgSrc = canvas.toDataURL('image/png')
        data.tablet.camera.img = imgSrc
      sharePicture: ->
        console.log "Sharing Picture"

  infoScreen =
    template: display.document.getElementById("info")

  mapsScreen =
    template: display.document.getElementById("maps")
    beforeMount: loadMaps
    beforeDestroy: unloadMaps

  netflixScreen =
    template: display.document.getElementById("netflix-template")
    data: ->
      return data.display.netflix

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
  tablet.state.camera.img = ""
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

loadMaps = ->
  display.state.maps.timer = setInterval updateLocation, 5000
  do updateLocation

unloadMaps = ->
  clearInterval display.state.maps.timer

updateLocation = ->
  locations =
    frontDoor: [608, 1080]
    rampBottom: [500, 1000]
    rampTop: [500, 818]
    window: [808, 890]
    stairBase: [770, 780]
    door132: [450, 650]
    elevator: [658, 502]
    mailboxes: [715, 205]
    door146: [450, 240]
    door151: [326, 94]
    junction140: [330, 412]
    door128: [500, 118]
    door141: [96, 410]
    door118: [888, 140]
    door112: [888, 478]
    stairTop: [760, 620]
  try
    $.getJSON "location/location.json", (location) ->
      [x, y] = locations[location]
      [maxLoc, maxVal] = [null, -10]
      for loc, val of location.bayes
        if val > maxVal
          [maxLoc, maxVal] = [loc, val]
      console.log maxVal
      [x_, y_] = locations[maxLoc]
      [dx, dy] = [(x_ - x) * 0.5 * maxVal, (y_ - y) * 0.5 * maxVal]
      display.state.maps.location = [x + dx, y + dy]
  catch error
    console.log "Error Updating Location", error

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
