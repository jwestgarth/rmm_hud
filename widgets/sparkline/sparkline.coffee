class Dashing.sparkline extends Dashing.Widget

  @accessor 'current', ->
    if @get('points')
      points = @get('points')
      points[points.length - 1].y
    else
      ""

  ready: ->
    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data('sizex')) + Dashing.widget_margins[0] * 2 * (container.data('sizex') - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data('sizey'))

    # Make the sparkline graph 1/4 of the widget's height
    height /= 4

    $graph = $("<div class='sparkline-container' style='height:#{height}px;'></div>")
    $(@node).append $graph

    @graph = new Rickshaw.Graph(
      element: $graph.get(0)
      width: width
      height: height
      renderer: @get('graphtype')
      series: [{
        color: '#fff',
        data: [{x:0, y:0}]
      }]
    )

    if @get('points')
      @graph.series[0].data = @get('points')
      @graph.render()

  onData: (data) ->
    if @graph && data.points
      @graph.series[0].data = data.points
      @graph.render()