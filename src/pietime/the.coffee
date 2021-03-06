PADDING = 25
INTERVALS = "second minute hour day week month year".split " "
COLORS = [
  "#fa8072"
  "#faad72"
  "#fada72"
  "#ecfa72"
  "#87ceeb"
  "#87aceb"
  "#a4b7eb"
]
PIXEL_RATIO = window.devicePixelRatio or 1

crel = (el) -> document.createElement el

intervals = []

draw = (interval) ->

  diff = moment().endOf(interval.name).diff(moment())
  percent = diff / interval.ms

  size = interval.canvas.width
  center = size / 2
  ctx = interval.context

  ctx.clearRect(0, 0, size, size)

  ctx.fillStyle = ctx.strokeStyle = interval.color

  radius = Math.max(center * percent, center * 0.9)

  ctx.beginPath()
  ctx.moveTo(center, center)
  ctx.arc(center, center, radius, 0, 2 * Math.PI)
  ctx.stroke()

  ctx.beginPath()
  ctx.moveTo(center, center)
  ctx.arc(center, center, radius, 0, 2 * Math.PI * percent)
  ctx.fill()

do ->

  fragment = document.createDocumentFragment()

  timelist = crel "ul"

  for interval, i in INTERVALS

    wrapper = crel "li"
    description = crel "div"
    canvas = crel "canvas"
    wrapper.appendChild canvas
    wrapper.appendChild description
    timelist.appendChild wrapper

    description.style.color = COLORS[i]
    description.innerHTML = interval

    intervals.push
      name: interval
      color: COLORS[i]
      ms: moment.duration(1, interval).asMilliseconds()
      canvas: canvas
      context: canvas.getContext "2d"

  fragment.appendChild(timelist)
  document.body.appendChild(fragment)

do window.onresize = ->

  width = window.innerWidth

  if width > 600
    size = (width - (PADDING * intervals.length)) / intervals.length
  else if width > 400
    size = (width - (PADDING * intervals.length)) / (intervals.length / 4)
  else
    size = width - (PADDING * intervals.length)

  for interval in intervals
    canvas = interval.canvas
    canvas.width = canvas.height = size * PIXEL_RATIO
    canvas.style.width = canvas.style.height = size + "px"
    draw interval

do ->

  # seconds and minutes have to be done as fast as possible.
  # the rest can be drawn much less frequently, for performance

  do secondsAndMinutes = ->
    draw intervals[0] # s
    draw intervals[1] # m
    requestAnimationFrame(secondsAndMinutes)

  startInterval ->
    draw interval for interval, i in intervals when i >= 2
  , 1000
